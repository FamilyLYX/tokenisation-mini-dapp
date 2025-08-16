"use server";
import { NextRequest, NextResponse } from "next/server";
import { uploadImageToS3 } from "@/lib/s3";

export async function POST(req: NextRequest) {
  const formData = await req.formData();
  const file = formData.get("file") as File;

  if (!file) {
    return NextResponse.json({ error: "No file provided" }, { status: 400 });
  }

  const arrayBuffer = await file.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const credentialsTest = {
    accessKeyId: process.env.NEXT_PUBLIC_ACCESS_KEY_ID ? "present" : "missing",
    secretAccessKey: process.env.NEXT_PUBLIC_SECRET_ACCESS_KEY
      ? "present"
      : "missing",
  };

  try {
    const url = await uploadImageToS3(buffer, file.name, file.type);
    return NextResponse.json({ url });
  } catch (err) {
    return NextResponse.json(
      { error: "Upload failed", details: err, credentialsTest },
      { status: 500 }
    );
  }
}
