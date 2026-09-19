import fs from "node:fs";
import path from "node:path";
import multer from "multer";
import { env } from "../config/env.js";
import { AppError } from "../utils/AppError.js";

const uploadRoot = path.resolve(process.cwd(), env.UPLOAD_DIR);

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

const storage = multer.diskStorage({
  destination(req, _file, cb) {
    const id = req.provider?.id || "pending";
    const dest = path.join(uploadRoot, "providers", id);
    ensureDir(dest);
    cb(null, dest);
  },
  filename(_req, file, cb) {
    const ext = path.extname(file.originalname || "").toLowerCase() || ".bin";
    const stamp = Date.now();
    const kind = file.fieldname === "photo" ? "photo" : "document";
    cb(null, `${kind}-${stamp}${ext}`);
  },
});

function fileFilter(_req, file, cb) {
  const allowed = new Set([
    "image/jpeg",
    "image/png",
    "image/webp",
    "application/pdf",
  ]);
  if (!allowed.has(file.mimetype)) {
    cb(new AppError(400, "Only JPEG, PNG, WEBP, or PDF files are allowed", "INVALID_FILE_TYPE"));
    return;
  }
  cb(null, true);
}

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: Math.max(env.MAX_PHOTO_MB, env.MAX_DOCUMENT_MB) * 1024 * 1024,
  },
});

export function publicFileUrl(file) {
  if (!file) return null;
  const relative = path.relative(process.cwd(), file.path).replaceAll("\\", "/");
  return `/${relative}`;
}
