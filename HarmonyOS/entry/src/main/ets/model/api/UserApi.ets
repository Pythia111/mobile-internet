import ApiClient from './ApiClient';
import http from '@ohos.net.http';
import { ApiResponse } from '../response/ApiResponse';

export interface UserProfile {
  userId: string;
  phone: string;
  username: string;
  avatar: string;
  role: string;
}

export async function getUserProfile(): Promise<ApiResponse<UserProfile>> {
  return await ApiClient.request<ApiResponse<UserProfile>>('/api/user/profile', {
    method: http.RequestMethod.GET
  });
}
