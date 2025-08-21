import { NextRequest, NextResponse } from "next/server";
import { saltServiceAdmin } from "../../../lib/firestore-admin";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { tokenId, contractAddress, salt, uidHash, productCode } = body;

    // Validate required fields
    if (!tokenId || !contractAddress || !salt || !uidHash || !productCode) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      );
    }

    const result = await saltServiceAdmin.create({
      tokenId,
      contractAddress,
      salt,
      uidHash,
      uidCode: productCode,
    });

    return NextResponse.json(result);
  } catch (error) {
    console.error("Error creating salt:", error);
    return NextResponse.json(
      { error: "Failed to create salt" },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const tokenId = searchParams.get("tokenId");
    const contractAddress = searchParams.get("contractAddress");

    if (!tokenId || !contractAddress) {
      return NextResponse.json(
        { error: "Missing tokenId or contractAddress" },
        { status: 400 }
      );
    }

    const result = await saltServiceAdmin.getByTokenAndContract(
      tokenId,
      contractAddress
    );

    if (!result) {
      return NextResponse.json({ error: "Salt not found" }, { status: 404 });
    }

    return NextResponse.json(result);
  } catch (error) {
    console.error("Error fetching salt:", error);
    return NextResponse.json(
      { error: "Failed to fetch salt" },
      { status: 500 }
    );
  }
}
