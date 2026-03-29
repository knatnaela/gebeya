import { env } from '../config/env';

const GATEWAY_BASE = 'https://gatewayapi.telegram.org/';

interface GatewayEnvelope<T> {
  ok: boolean;
  result?: T;
  error?: string;
}

export interface RequestStatusResult {
  request_id: string;
  phone_number?: string;
  verification_status?: {
    status: string;
  };
}

async function gatewayPost<T>(method: string, body: Record<string, unknown>): Promise<T> {
  const token = env.TELEGRAM_GATEWAY_ACCESS_TOKEN;
  if (!token) {
    console.error('[telegram-gateway] Missing TELEGRAM_GATEWAY_ACCESS_TOKEN');
    throw new Error('Telegram Gateway is not configured');
  }

  const url = `${GATEWAY_BASE}${method}`;
  let res: Response;
  try {
    res = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(body),
    });
  } catch (err) {
    console.error('[telegram-gateway] Network error calling', method, err);
    throw err;
  }

  if (!res.ok) {
    let bodyText = '';
    try {
      bodyText = await res.text();
    } catch {
      /* ignore */
    }
    console.error('[telegram-gateway] HTTP error', method, res.status, bodyText.slice(0, 500));
    throw new Error(`Telegram Gateway HTTP ${res.status}`);
  }

  const json = (await res.json()) as GatewayEnvelope<T>;
  if (!json.ok) {
    console.error('[telegram-gateway] API error', method, json.error ?? json);
    throw new Error(json.error || 'Telegram Gateway request failed');
  }
  if (json.result === undefined) {
    console.error('[telegram-gateway] Missing result', method, json);
    throw new Error('Telegram Gateway returned no result');
  }
  return json.result;
}

/**
 * Send verification code to E.164 phone via Telegram Gateway.
 * @returns Gateway request_id
 */
export async function sendVerificationMessage(params: {
  phoneNumberE164: string;
  ttlSeconds?: number;
  codeLength?: number;
  payload?: string;
}): Promise<string> {
  const ttl = params.ttlSeconds ?? 300;
  const result = await gatewayPost<RequestStatusResult>('sendVerificationMessage', {
    phone_number: params.phoneNumberE164,
    ttl: Math.min(3600, Math.max(30, ttl)),
    code_length: params.codeLength ?? 6,
    ...(params.payload ? { payload: params.payload.slice(0, 128) } : {}),
  });
  if (!result.request_id) {
    console.error('[telegram-gateway] sendVerificationMessage: no request_id in result', result);
    throw new Error('Telegram Gateway did not return request_id');
  }
  return result.request_id;
}

/**
 * Verify user-entered code with Telegram Gateway.
 */
export async function checkVerificationStatus(requestId: string, code: string): Promise<boolean> {
  const result = await gatewayPost<RequestStatusResult>('checkVerificationStatus', {
    request_id: requestId,
    code: code.trim(),
  });
  const status = result.verification_status?.status;
  return status === 'code_valid';
}

export function isTelegramGatewayConfigured(): boolean {
  return Boolean(env.TELEGRAM_GATEWAY_ACCESS_TOKEN?.trim());
}
