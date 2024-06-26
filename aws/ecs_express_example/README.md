# AWS ECS Express Example

Sample project to demonstrate how to deploy an Express.js application to AWS ECS.

Inspired by this [tutorial](https://youtu.be/ngupV3Y_fvw?si=2rSqcrI0ddP-7ZnD) by AWS With Atiq.

## Running the Express App Locally

To see the scripts involved in running the Express app locally, check the `scripts` section in `package.json`.

### Prerequisites
- Node.js
- npm
- yarn
- docker

### Steps (Local)
1. Install dependencies
    ```bash
    yarn
    ```
2. Start the Express app with a non-priviliged port
    ```bash
    PORT=3030 yarn start
    ```
3. Open a browser and navigate to `http://localhost:3030`
4. You should see the message `Hello World!`

### Steps (Docker)
1. Build the Docker image
    ```bash
    yarn docker:build
    ```
2. Run the Docker container
    ```bash
    yarn docker:run
    ```
3. Open a browser and navigate to `http://localhost:80`
4. Alternatively, make a GET request to `http://localhost:80` using `curl` or `Postman`
    ```bash
    # Using the script in package.json
    yarn docker:get_request
    # Using curl
    curl http://localhost:80
    ```
5. To kill the container, run
    ```bash
    yarn docker:kill
    ```

### Steps (Deployment)
1. Initialize Terraform
    ```bash
    yarn tf:init
    ```
2. Deploy Terraform resources
    ```bash
    yarn tf:plan
    yarn tf:apply
    ```
3. Go to the [EC2 dashboard](https://console.aws.amazon.com/ec2/) in the AWS console and find the public IP of the EC2 instance
4. Either `curl` or navigate to the public IP in a browser
    ```bash
    # Using curl
    curl <public_ip>
    # Or go to http://<public_ip>
    ```
5. See the message `Hello World!`
6. To destroy the Terraform resources, run
    ```bash
    yarn tf:destroy
    ```

## Things to take note of
### HTTP(S)
We have no SSL certs or anything, so this only works on HTTP. If you want to run this on HTTPS, you will need to get SSL certs. (See [this StackOverflow thread](https://stackoverflow.com/questions/11744975/enabling-https-on-express-js) for more info)
We run this app on port 80 (mapped to host port 80) in the Docker container. This is because the default port for HTTP is 80.

### ECS + Auto Scaling Group integration
When letting an Auto Scaling Group manage EC2 instances for the ECS cluster, you may notice that the instances are not registered with the ECS cluster. To make your EC2 instances (from ASG) register with your ECS cluster, there are four things that need to be done ([SO](https://stackoverflow.com/questions/36523282/aws-ecs-error-when-running-task-no-container-instances-were-found-in-your-clust), [docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html)):

1. EC2 instances must have the correct IAM role attached to them. This IAM role should have the `AmazonEC2ContainerServiceforEC2Role` policy attached to it ([docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html)).
   - In Terraform, this is done through the `iam_instance_profile` in the `aws_launch_template` resource.
2. EC2 instances must be running an ECS agent, typically through an `ecs-optimized` AMI image ([docs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html#linux-liw-ami)).
3. EC2 instances must have access to the internet (typically via internet or NAT gateawy)
4. EC2 instances must have the ECS cluster name stored in the `/etc/ecs/ecs.config` file.
   - Typically done through the `user_data` script in the `aws_launch_template` resource:
    ```bash
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${ECS_CLUSTER_NAME}
    EOF
    ```
## Updating ECS Task Definitions
One problem with the `aws_ecs_task_definition` resource is that when you update the Docker container, the task definition is not updated. To get around this, we specify the the sha256 of the Docker image in the `container_definitions` field of the `aws_ecs_task_definition` resource. This way, when the Docker image is updated, the sha256 will change and Terraform will update the task definition.

## `terraform destroy` with an AutoScaling Group
When you run `terraform destroy` with an AutoScaling Group, Terraform will not be able to destroy the EC2 instances created by the AutoScaling Group because it is not tracked by Terraform. To get around this, this project uses the [`local-exec` provisioner](./terraform/ecs.tf#L107) to run a script that will delete the EC2 instances associated with the AutoScaling Group.
