import { AxiosError } from "axios";


export const upload_file_from_s3_presigned_link = async function (
  url: string,
  file: File
): Promise<null> {
  const formData = new FormData();
  formData.append("file", file);

  try {
    const xhr = new XMLHttpRequest();
    xhr.open("PUT", url, true);
    xhr.send(formData);
    return null;
  } catch (e: unknown) {
    if (!(e instanceof AxiosError)) throw e;

    throw e;
  }
};
