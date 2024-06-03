import { useState } from 'react'
import './App.css'
import { createPresignedUrl } from './lib/presign';
import { upload_file_from_s3_presigned_link } from './lib/upload';

const upload = async (file: File | null) => {
  if (!file) return;

  const presignedURL = await createPresignedUrl(file.name);
  return await upload_file_from_s3_presigned_link(presignedURL, file);

}
function App() {
  const [file, setFile] = useState<File | null>(null)
  return (
    <>
      <input type="file" name="" id="" onChange={e => setFile(e.target.files![0] ?? null)} />
      <button onClick={() => upload(file)}>Upload file</button>
    </>
  )
}

export default App
