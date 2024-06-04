import {
  CompleteMultipartUploadCommand,
  CompleteMultipartUploadCommandOutput,
  CreateMultipartUploadCommand,
  PutObjectCommand,
  S3Client,
  UploadPartCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { CompletedPart } from "@aws-sdk/client-s3";

const accessKeyId = import.meta.env.VITE_IAM_USER;
const secretAccessKey = import.meta.env.VITE_IAM_KEY;
const bucketName = import.meta.env.VITE_UPLOAD_BUCKET;
const region = import.meta.env.VITE_AWS_REGION;


const s3Client = new S3Client({
  region,
  credentials: { accessKeyId, secretAccessKey },
});

export const createPresignedUrlUpload = function (
  key: string
): Promise<string> {
  const command = new PutObjectCommand({ Bucket: bucketName, Key: key });
  return getSignedUrl(s3Client, command, { expiresIn: 3600 });
};

export const startMultipartUpload = async function (
  key: string
): Promise<string> {
  const startUploadCommand = new CreateMultipartUploadCommand({
    Bucket: bucketName,
    Key: key,
  });
  const result = await s3Client.send(startUploadCommand);
  return result.UploadId!;
};

export const createPresignedUrlsForEachMultipartUpload = function (
  key: string,
  parts: number,
  uploadId: string
): Promise<string[]> {
  const uploadPartUrls: Promise<string>[] = [];
  for (let i = 1; i <= parts; i++) {
    const uploadPartCommand = new UploadPartCommand({
      Bucket: bucketName,
      Key: key,
      PartNumber: i,
      UploadId: uploadId,
    });
    uploadPartUrls.push(
      getSignedUrl(s3Client, uploadPartCommand, { expiresIn: 3600 })
    );
  }
  return Promise.all(uploadPartUrls);
};

export const completeMultipartUpload = function (
  key: string,
  uploadId: string,
  completedParts: CompletedPart[]
): Promise<CompleteMultipartUploadCommandOutput> {
  const uploadPartCommand = new CompleteMultipartUploadCommand({
    Bucket: bucketName,
    Key: key,
    UploadId: uploadId,
    MultipartUpload: { Parts: completedParts },
  });
  return s3Client.send(uploadPartCommand);
};
