import http from '@ohos.net.http';

export default class ApiClient {
  static baseUrl: string = 'http://localhost:8080';

  static async request<T>(path: string, options?: http.HttpRequestOptions): Promise<T> {
    const url = ApiClient.baseUrl + path;
    const httpRequest = http.createHttp();
    
    try {
      const response = await httpRequest.request(url, options);
      if (response.responseCode === 200) {
        const result = response.result;
        if (typeof result === 'string') {
           return JSON.parse(result) as T;
        }
        return result as T;
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      console.error('ApiClient.request error', JSON.stringify(err));
      throw new Error(JSON.stringify(err));
    } finally {
      httpRequest.destroy();
    }
  }
}
