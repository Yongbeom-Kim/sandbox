import axios, { AxiosError, AxiosResponse } from "axios";
import {
  completeMultipartUpload,
  createPresignedUrlsForEachMultipartUpload,
  startMultipartUpload,
} from "./presign";
import { CompletedPart } from "@aws-sdk/client-s3";

export const uploadFromPresignedLink = async function (
  url: string,
  file: File
): Promise<null> {
  const formData = new FormData();
  formData.append("file", file);

  try {
    await axios.put(url, formData, {
      validateStatus: (status: number) => status < 300,
    });
    return null;
  } catch (e: unknown) {
    if (!(e instanceof AxiosError)) throw e;
    throw e;
  }
};

export const uploadMultipart = async function (
  file: File,
  parts: number
): Promise<null> {
  try {
    const key = file.name;

    const uploadId = await startMultipartUpload(key)

    const partUploadUrls: string[] =
      await createPresignedUrlsForEachMultipartUpload(key, parts, uploadId);
    const uploadPromises: Promise<AxiosResponse>[] = partUploadUrls.map((url, i) => {
      const formData = new FormData();
      formData.append(
        "file",
        file.slice(
          i * Math.ceil(file.size / parts),
          (i + 1) * Math.ceil(file.size / parts)
        )
      );
      return axios.put(url, formData, {
        validateStatus: (status: number) => status < 300,
      });
    })
    const uploadResults = await Promise.all(uploadPromises);
    const etags: string[] = uploadResults.map((result) => result.headers.etag)
    const completedParts: CompletedPart[] = etags.map((etag, i) => {
      return { ETag: etag.replace("\"", ""), PartNumber: i + 1 }
    });

    await completeMultipartUpload(
      key,
      uploadId,
      completedParts
    );

    return null;
  } catch (e: unknown) {
    if (!(e instanceof AxiosError)) throw e;

    throw e;
  }
};
