import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

const accessKeyId = import.meta.env.VITE_IAM_USER;
const secretAccessKey = import.meta.env.VITE_IAM_KEY;
const bucketName = import.meta.env.VITE_UPLOAD_BUCKET;
const region = import.meta.env.VITE_AWS_REGION;

export const createPresignedUrl = (key: string) => {
  const client = new S3Client({ region, credentials: {accessKeyId, secretAccessKey} });
  const command = new PutObjectCommand({ Bucket: bucketName, Key: key });
  return getSignedUrl(client, command, { expiresIn: 3600 });
};
