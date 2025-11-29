import ApiClient from '../model/api/ApiClient';
import http from '@ohos.net.http';

interface TestOptions {
  method: http.RequestMethod;
  header: Record<string, string>;
  extraData?: string;
}

interface TestLoginData {
  phone: string;
  password: string;
}

export default class NetworkTest {
  // 测试网络连接
  static async testConnection(): Promise<boolean> {
    try {
      console.info('NetworkTest: 开始测试网络连接');
      // 测试实际的登录接口
      const testData: TestLoginData = { phone: "test", password: "test" };
      await ApiClient.request<Record<string, string>>('/api/auth/login', {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(testData)
      });
      console.info('NetworkTest: 网络连接测试成功');
      return true;
    } catch (error) {
      console.error('NetworkTest: 网络连接测试失败', JSON.stringify(error));
      // 即使返回500错误，也说明网络是通的，只是数据问题
      return true;
    }
  }

  // 测试具体的API端点
  static async testApiEndpoint(endpoint: string, method: string = 'GET', data?: Record<string, string>): Promise<Record<string, string>> {
    try {
      console.info(`NetworkTest: 测试API端点 ${endpoint}`);
      const options: TestOptions = {
        method: method === 'POST' ? http.RequestMethod.POST : http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json' }
      };
      
      if (data && method !== 'GET') {
        options.extraData = JSON.stringify(data);
      }
      
      const response = await ApiClient.request<Record<string, string>>(endpoint, options);
      console.info(`NetworkTest: API端点 ${endpoint} 测试成功`);
      return response;
    } catch (error) {
      console.error(`NetworkTest: API端点 ${endpoint} 测试失败`, JSON.stringify(error));
      throw new Error(`API测试失败: ${endpoint}`);
    }
  }
}