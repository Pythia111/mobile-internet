// common/api.js
import http from '@ohos.net.http';

export class HttpService {
  static instance = null;
  httpClient = null;
  baseURL = 'http://localhost:8081/api';

  constructor() {
    this.httpClient = http.createHttp();
  }

  static getInstance() {
    if (!HttpService.instance) {
      HttpService.instance = new HttpService();
    }
    return HttpService.instance;
  }

  async getToken() {
    return 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMzgwMTU1NDYiLCJpYXQiOjE3NjQ0Mzg5NDYsImV4cCI6MTc2NDUyNTM0Nn0.UjbcNay-6SGpFHwKUrzTqpN4RS8H2WKi0pvJnDVxCdU';
  }

  async getHeaders() {
    const token = await this.getToken();
    console.log('🔑 使用有效Token进行API请求');

    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };
  }

  // 手动构建查询参数（完全替代 URLSearchParams）
  buildQueryString(params) {
    if (!params || Object.keys(params).length === 0) {
      return '';
    }

    const queryParts = [];
    for (const key in params) {
      if (params.hasOwnProperty(key)) {
        const value = params[key];
        if (value !== null && value !== undefined) {
          // 对键和值进行编码
          const encodedKey = encodeURIComponent(key);
          const encodedValue = encodeURIComponent(value.toString());
          queryParts.push(encodedKey + '=' + encodedValue);
        }
      }
    }

    return queryParts.length > 0 ? '?' + queryParts.join('&') : '';
  }

  async get(url, params = {}) {
    try {
      const headers = await this.getHeaders();

      // 确保URL格式正确
      let fullUrl = this.baseURL;
      if (url.startsWith('/')) {
        fullUrl += url;
      } else {
        fullUrl += '/' + url;
      }

      // 使用自定义方法构建查询字符串
      const queryString = this.buildQueryString(params);
      fullUrl += queryString;

      console.log('🌐 发送GET请求:', fullUrl);

      const response = await this.httpClient.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: headers
      });

      console.log('✅ 响应状态:', response.responseCode);
      console.log('📦 响应结果:', response.result);

      const result = JSON.parse(response.result);

      if (result.code === 200) {
        console.log('🎯 API请求成功，返回数据:', result.data);
        return result.data;
      } else {
        console.error('❌ API返回错误:', result.message);
        throw new Error(result.message || 'API返回错误');
      }
    } catch (error) {
      console.error('❌ GET请求失败:', error.message);
      throw error;
    }
  }

  async post(url, data) {
    try {
      const headers = await this.getHeaders();

      // 确保URL格式正确
      let fullUrl = this.baseURL;
      if (url.startsWith('/')) {
        fullUrl += url;
      } else {
        fullUrl += '/' + url;
      }

      const options = {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(data)
      };

      console.log('🌐 发送POST请求:', fullUrl);
      console.log('📦 请求数据:', JSON.stringify(data));

      const response = await this.httpClient.request(fullUrl, options);
      console.log('✅ 响应状态:', response.responseCode);

      const result = JSON.parse(response.result);

      if (result.code === 200) {
        console.log('🎯 POST请求成功');
        return result.data;
      } else {
        console.error('❌ API返回错误:', result.message);
        throw new Error(result.message || '请求失败');
      }
    } catch (error) {
      console.error('❌ POST请求失败:', error.message);
      throw error;
    }
  }

  async delete(url) {
    try {
      const headers = await this.getHeaders();

      let fullUrl = this.baseURL;
      if (url.startsWith('/')) {
        fullUrl += url;
      } else {
        fullUrl += '/' + url;
      }

      const options = {
        method: http.RequestMethod.DELETE,
        header: headers
      };

      console.log('🌐 发送DELETE请求:', fullUrl);

      const response = await this.httpClient.request(fullUrl, options);
      const result = JSON.parse(response.result);

      if (result.code === 200) {
        return result;
      } else {
        throw new Error(result.message || '删除失败');
      }
    } catch (error) {
      console.error('DELETE请求失败:', error);
      throw error;
    }
  }
}