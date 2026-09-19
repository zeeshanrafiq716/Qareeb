export class AppError extends Error {
  constructor(statusCode, message, code = "APP_ERROR", details = undefined) {
    super(message);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
  }
}

export class ValidationError extends AppError {
  constructor(message, details) {
    super(400, message, "VALIDATION_ERROR", details);
    this.name = "ValidationError";
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Authentication required") {
    super(401, message, "UNAUTHORIZED");
    this.name = "UnauthorizedError";
  }
}

export class ForbiddenError extends AppError {
  constructor(message = "Not allowed") {
    super(403, message, "FORBIDDEN");
    this.name = "ForbiddenError";
  }
}

export class NotFoundError extends AppError {
  constructor(message = "Resource not found") {
    super(404, message, "NOT_FOUND");
    this.name = "NotFoundError";
  }
}

export class ConflictError extends AppError {
  constructor(message, code = "CONFLICT") {
    super(409, message, code);
    this.name = "ConflictError";
  }
}
