import http from '@ohos.net.http';
import { ApiConfig } from '../../config/ApiConfig';
import TokenManager from '../../utils/TokenManager';

export default class ApiClient {
  static async request<T>(path: string, options?: http.HttpRequestOptions): Promise<T> {
    const url = ApiConfig.getCurrentBaseUrl() + path;
    const httpRequest = http.createHttp();
    
    // 获取 Token 并添加到请求头
    const token = await TokenManager.getToken();
    const finalOptions = options || { method: http.RequestMethod.GET };
    
    if (!finalOptions.header) {
      finalOptions.header = {};
    }
    
    if (token) {
      finalOptions.header['Authorization'] = `Bearer ${token}`;
    }

    console.info(`ApiClient: 发起请求 ${url}`);
    console.info(`ApiClient: 请求参数`, JSON.stringify(finalOptions));
    
    try {
      const response = await httpRequest.request(url, finalOptions);
      console.info(`ApiClient: 响应状态码 ${response.responseCode}`);
      console.info(`ApiClient: 响应数据`, JSON.stringify(response.result));
      
      if (response.responseCode === 200) {
        const result = response.result;
        if (typeof result === 'string') {
           return JSON.parse(result) as T;
        }
        return result as T;
      } else {
        const errorMsg = `HTTP Error: ${response.responseCode}`;
        console.error('ApiClient:', errorMsg);
        throw new Error(errorMsg);
      }
    } catch (err) {
      console.error('ApiClient.request error', JSON.stringify(err));
      // 更详细的错误处理
      if (err.message && err.message.includes('Network')) {
        throw new Error('网络连接失败，请检查网络设置');
      } else if (err.message && err.message.includes('timeout')) {
        throw new Error('请求超时，请稍后重试');
      } else {
        throw new Error(`请求失败: ${JSON.stringify(err)}`);
      }
    } finally {
      httpRequest.destroy();
    }
  }
}
