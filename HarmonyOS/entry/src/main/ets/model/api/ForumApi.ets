import ApiClient from './ApiClient';
import http from '@ohos.net.http';
import { ApiResponse } from '../response/ApiResponse';

export interface Post {
  postId: string;
  title: string;
  userId: string;
  username: string;
  images?: string[];
  avatar: string;
  status: number;
  likeCount: number;
}

export interface PostDetailData extends Post {
  content: string;
  comments: Comment[];
}

export interface Comment {
  commentId: string;
  content: string;
  userId: string;
  username: string;
  avatar?: string; // 补充头像字段
}

export interface CreatePostRequest {
  title: string;
  content: string;
  images: string[];
  creatorName: string;
  creatorAvatar: string; // 接口文档要求必填
}

export interface PostListResponse {
  posts: Post[];
}

export async function getPosts(status: number = 0): Promise<ApiResponse<PostListResponse>> {
  return await ApiClient.request<ApiResponse<PostListResponse>>(`/api/forum/posts?status=${status}`, {
    method: http.RequestMethod.GET
  });
}

export async function getMyPosts(): Promise<ApiResponse<Post[]>> {
  return await ApiClient.request<ApiResponse<Post[]>>('/api/forum/my-posts', {
    method: http.RequestMethod.GET
  });
}

export async function getPostDetail(postId: string): Promise<ApiResponse<PostDetailData>> {
  return await ApiClient.request<ApiResponse<PostDetailData>>(`/api/forum/posts/${postId}`, {
    method: http.RequestMethod.GET
  });
}

export interface LikeResponse {
  liked: boolean;
}

export async function likePost(postId: string): Promise<ApiResponse<LikeResponse>> {
  return await ApiClient.request<ApiResponse<LikeResponse>>(`/api/forum/posts/${postId}/like`, {
    method: http.RequestMethod.POST
  });
}

export async function commentPost(postId: string, content: string, username: string, avatar: string): Promise<ApiResponse<Comment>> {
  return await ApiClient.request<ApiResponse<Comment>>(`/api/forum/posts/${postId}/comments`, {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': 'application/json' },
    extraData: JSON.stringify({ content, username, avatar })
  });
}

export async function createPost(post: CreatePostRequest): Promise<ApiResponse<Record<string, Object>>> {
  return await ApiClient.request<ApiResponse<Record<string, Object>>>('/api/forum/posts', {
    method: http.RequestMethod.POST,
    header: { 'Content-Type': 'application/json' },
    extraData: JSON.stringify(post)
  });
}
