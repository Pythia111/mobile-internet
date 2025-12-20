import ApiClient from './ApiClient';
import http from '@ohos.net.http';
import { ApiResponse } from '../response/ApiResponse';

interface LoginRequest {
  phone: string;
  password: string;
}

interface RegisterRequest {
  phone: string;
  password: string;
  username: string;
}

interface LoginResponseData {
  userId: string;
  token: string;
  role: string;
}

interface RegisterResponseData {
  userId: string;
  token: string;
}

export async function login(phone: string, password: string): Promise<ApiResponse<LoginResponseData>> {
  const body: LoginRequest = { phone, password };
  return await ApiClient.request<ApiResponse<LoginResponseData>>('/api/auth/login', {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': 'application/json' },
    extraData: JSON.stringify(body),
  });
}

export async function register(phone: string, password: string, username: string): Promise<ApiResponse<RegisterResponseData>> {
  const body: RegisterRequest = { phone, password, username };
  return await ApiClient.request<ApiResponse<RegisterResponseData>>('/api/auth/register', {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': 'application/json' },
    extraData: JSON.stringify(body),
  });
}
