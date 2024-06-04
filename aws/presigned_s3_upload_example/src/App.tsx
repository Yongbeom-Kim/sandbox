import { useEffect, useState } from "react";
import "./App.css";
import {
  createPresignedUrlUpload,
} from "./lib/presign";
import {
  uploadFromPresignedLink,
  uploadMultipart,
} from "./lib/upload";

const upload = async (file: File | null) => {
  if (!file) return;

  const presignedURL = await createPresignedUrlUpload(file.name);
  return await uploadFromPresignedLink(presignedURL, file);
};

const multipartUpload = async (file: File | null, parts: number) => {
  if (!file) return;
  if (!parts) return;
  return await uploadMultipart(file, parts);
};

function App() {
  const [file, setFile] = useState<File | null>(null);
  const [uploadPartLength, setUploadPartLength] = useState<number>(1);
  const [status, setStatus] = useState('');

  useEffect(() => {
    if (!file) {
      setStatus('No file selected');
      return;
    }
    if (uploadPartLength != 1 && uploadPartLength * 5 * 1024 * 1024 > (file?.size ?? 0)) {
      setStatus('Part number is too large');
      return;
    }
    setStatus('Ready for Upload');
  }, [file])

  return (
    <form>
      <input
        type="file"
        name=""
        id=""
        onChange={(e) => setFile(e.target.files![0] ?? null)}
      />
      <button
        onClick={(e) => {
          e.preventDefault();
          setStatus('Uploading...')
          upload(file).then(() => setStatus('Uploaded')).catch(() => setStatus('Uploading Failed'));
        }}
        disabled={!file}
      >
        Upload file (Single)
      </button>
      <div>
        <input
          type="number"
          min={1}
          max={Math.ceil(((file?.size ?? 0) / (5* 1024 * 1024)))}
          placeholder="Parts"
          onChange={(e) => setUploadPartLength(Number.parseInt(e.target.value) ?? 1)}
        />
        <button
          onClick={(e) => {
            e.preventDefault();
            setStatus('Uploading...')
            multipartUpload(file, uploadPartLength).then(() => setStatus('Uploaded')).catch(() => setStatus('Uploading Failed'));
          }}
          disabled={!file || (uploadPartLength != 1 && uploadPartLength * 5 * 1024 * 1024 > (file?.size ?? 0))}
        >
          Upload file (multi-part)
        </button>
      </div>
      <div>
        Status: {status}
      </div>
    </form>
  );
}

export default App;
