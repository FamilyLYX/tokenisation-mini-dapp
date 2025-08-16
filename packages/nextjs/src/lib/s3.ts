import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { v4 as uuidv4 } from "uuid";
import { Buffer } from "buffer";

const s3 = new S3Client({
  region: process.env.REGION!,
  credentials: {
    accessKeyId: process.env.ACCESS_KEY_ID!,
    secretAccessKey: process.env.SECRET_ACCESS_KEY!,
  },
});

export async function uploadImageToS3(
  fileBuffer: Buffer,
  fileName: string,
  mimeType: string
) {
  try {
    const Key = `uploads/${uuidv4()}-${fileName}`;

    const command = new PutObjectCommand({
      Bucket: process.env.S3_BUCKET!,
      Key,
      Body: fileBuffer,
      ContentType: mimeType,
    });

    await s3.send(command);

    return `https://${process.env.S3_BUCKET}.s3.${process.env.REGION}.amazonaws.com/${Key}`;
  } catch (error) {
    throw {
      error,
      message: "Failed to upload image to S3",
      bucket: process.env.S3_BUCKET,
      region: process.env.REGION,
      key: process.env.ACCESS_KEY_ID ? "present" : "missing",
      secret: process.env.SECRET_ACCESS_KEY ? "present" : "missing",
    };
  }
}
