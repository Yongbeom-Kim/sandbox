# S3 Uploads with Presigned URLs

This is a simple example of how to upload files to an S3 bucket using presigned URLs (both single and multi-part).

## Usage
1. Clone the repository
2. Run `yarn`
3. Run `make init`, `make plan` and `make apply` to create the S3 bucket with an AMI user with the necessary permissions to upload to the S3 bucket.
4. Run `make serve` to serve the Vite app that will allow you to upload files to the S3 bucket.
5. Open the browser and navigate to `http://localhost:5173`
6. Select the file, and upload (single-part) or upload (multi-part), specifying the number of parts.
7. Check the S3 bucket to see the uploaded files.

## Notes
`presign.ts` is a file that is meant to live on a backend server, and `upload.ts` is the file that is meant to live on the frontend, that interfaces with `presign.ts`. For simplicity, they both live on the frontend.

For the multi-part upload, the upload is done via the following process.
1. `presign.ts` initialises the multi-part upload.
2. `presign.ts` generates the presigned URLs for each part.
3. Each URL is passed to `upload.ts`, which uploads each part to the S3 bucket.
4. Upon completion, `upload.ts` calls the relevant function on `presign.ts` to complete the multi-part upload.

## Resources
- [Create a presigned URL for Amazon S3 using an AWS SDK](https://docs.aws.amazon.com/AmazonS3/latest/userguide/example_s3_Scenario_PresignedUrl_section.html)
- [CreateMultipartUpload - AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/API/API_CreateMultipartUpload.html)
- [UploadPart - AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPart.html)
- [CompleteMultipartUpload - AWS S3](https://docs.aws.amazon.com/AmazonS3/latest/API/API_CompleteMultipartUpload.html)
- [Stackoverflow thread](https://stackoverflow.com/questions/66656565/aws-sdk-multipart-upload-to-s3-with-node-js)