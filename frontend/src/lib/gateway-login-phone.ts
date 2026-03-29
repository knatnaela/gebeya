/** Session fallback when query `rid` is missing (e.g. refresh). */
export const GATEWAY_LOGIN_REQUEST_STORAGE_KEY = 'gebeya_gateway_login_request_id';

/** Matches mobile `auth_repository` parsing of `/auth/login/gateway/start` payload. */
export function parseGatewayStartRequestId(data: unknown): string | undefined {
  if (data == null || typeof data !== 'object') return undefined;
  const d = data as Record<string, unknown>;
  const raw = d.requestId ?? d.request_id;
  if (typeof raw === 'string' && raw.trim()) return raw.trim();
  return undefined;
}
