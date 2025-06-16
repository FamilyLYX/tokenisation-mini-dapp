import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(request: NextRequest) {
  // Only apply to /api routes
  if (!request.nextUrl.pathname.startsWith("/api")) {
    return NextResponse.next();
  }

  const apiKey = request.headers.get("x-api-key");
  const validApiKey = process.env.NEXT_PUBLIC_API_SECRET_KEY;

  if (!validApiKey) {
    console.error("API_KEY environment variable is not set");
    return NextResponse.json(
      { error: "Server configuration error" },
      { status: 500 }
    );
  }

  if (!apiKey || apiKey !== validApiKey) {
    return NextResponse.json(
      { error: "Unauthorized - Invalid API Key" },
      { status: 401 }
    );
  }

  return NextResponse.next();
}

// Configure the paths that should be protected by the middleware
export const config = {
  matcher: "/api/:path*",
};
