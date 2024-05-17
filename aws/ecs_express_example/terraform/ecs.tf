## ECS Cluster

resource "aws_ecs_cluster" "cluster" {
  name = "${var.service_name}-cluster"
}

## Capacity Provider

# AWS Linux 2023 AMI
data "aws_ami" "default_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-kernel-*"]
    # values = ["al2023-ami-2023*-kernel-*"]
  }

  # filter {
  #   name   = "owner-id"
  #   values = ["591542846629"] # Amazon
  # }
}

data "aws_iam_policy_document" "instance_profile_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "instance_role_policy" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "instance_profile_role" {
  name               = "${var.service_name}-instance-profile-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_profile_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "instance_profile_role" {
  role       = aws_iam_role.instance_profile_role.name
  policy_arn = data.aws_iam_policy.instance_role_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.service_name}-instance-profile"
  role = aws_iam_role.instance_profile_role.name
}

resource "aws_launch_template" "t2micro" {
  name_prefix   = "${var.service_name}-lt"
  image_id      = data.aws_ami.default_ami.id
  instance_type = "t2.micro"

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  network_interfaces {
    subnet_id                   = aws_subnet.public.id
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.allow_http_https.id,
      aws_security_group.allow_ssh.id,
      aws_security_group.allow_all_outbound.id
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.service_name}-instance"
    }
  }

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html#linux-liw-advanced-details
  user_data = base64encode(<<-EOF
              #!/bin/bash
              cat <<'EOF' >> /etc/ecs/ecs.config
              ECS_CLUSTER=${aws_ecs_cluster.cluster.name}
              EOF
  )
}

resource "aws_autoscaling_group" "ec2_capacity" {
  # Terminate EC2 instances when the ASG is destroyed
  # This block is at the top of the resource block so that it is executed first (before the resource is destroyed).
  provisioner "local-exec" {
    when = destroy
    interpreter = [ "/bin/bash", "-c"]
    command =<<-EOT
        INSTANCES=($(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${self.id} --query "AutoScalingGroups[0].Instances[].InstanceId" --output text))
        for i in "$${INSTANCES[@]}"; do
          aws ec2 terminate-instances --instance-ids $i || true
        done
        EOT
  }

  name_prefix      = "${var.service_name}-asg"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  instance_maintenance_policy {
    min_healthy_percentage = 0
    max_healthy_percentage = 100
  }

  launch_template {
    id      = aws_launch_template.t2micro.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
  }
}

output "ec2_capacity_provider" {
  value = aws_autoscaling_group.ec2_capacity
}

output "ec2_launch_template" {
  value = aws_launch_template.t2micro
}

resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = "${var.service_name}-ecs-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ec2_capacity.arn
    managed_draining       = "ENABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ec2_capacity_provider" {
  capacity_providers = [aws_ecs_capacity_provider.ec2_capacity_provider.name]
  cluster_name       = aws_ecs_cluster.cluster.name

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
    weight            = 1
    base              = 0
  }
}

## Task Definition

resource "aws_ecs_task_definition" "service" {
  family = "${var.service_name}-task-definition"
  container_definitions = jsonencode([{
    "name"      = "${var.service_name}-task-definition",
    "image"     = "${docker_registry_image.image.name}@${docker_registry_image.image.sha256_digest}",
    "cpu"       = 1024,
    "memory"    = 512,
    "essential" = true,
    "portMappings" = [
      {
        "containerPort" = 80,
        "hostPort"      = 80
      }
    ]
  }])
}

## Run task as service
resource "aws_ecs_service" "service" {
  name    = "${var.service_name}-service"
  cluster = aws_ecs_cluster.cluster.arn

  deployment_minimum_healthy_percent = 0
  force_new_deployment               = true

  desired_count = 1

  task_definition = aws_ecs_task_definition.service.arn

  capacity_provider_strategy {
    base              = 1
    capacity_provider = aws_ecs_capacity_provider.ec2_capacity_provider.name
    weight            = 100
  }
}
