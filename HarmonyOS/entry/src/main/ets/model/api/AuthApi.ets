import ApiClient from './ApiClient.js';

export async function login(phone: string, password: string) {
  const body = { phone, password };
  return await ApiClient.request('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

export async function register(phone: string, password: string, username: string) {
  const body = { phone, password, username };
  return await ApiClient.request('/api/auth/register', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}
