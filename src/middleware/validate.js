export function validate(schema) {
  return (req, _res, next) => {
    try {
      const parsed = schema.parse({
        body: req.body ?? {},
        params: req.params ?? {},
        query: req.query ?? {},
      });
      if (parsed.body !== undefined) req.body = parsed.body;
      req.validated = parsed;
      next();
    } catch (error) {
      next(error);
    }
  };
}

/** Express 5 does not allow assigning to req.query — use this after validate(). */
export function validatedQuery(req) {
  return req.validated?.query ?? req.query ?? {};
}

export function validatedParams(req) {
  return req.validated?.params ?? req.params ?? {};
}

export function validatedBody(req) {
  return req.validated?.body ?? req.body ?? {};
}
