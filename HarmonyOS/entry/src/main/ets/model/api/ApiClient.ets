export default class ApiClient {
  static baseUrl: string = 'http://localhost:8080';

  static async request(path: string, options?: any) {
    const url = ApiClient.baseUrl + path;
    const init = options || {};
    try {
      const resp = await fetch(url, init);
      const json = await resp.json();
      return json;
    } catch (err) {
      console.error('ApiClient.request error', err);
      throw err;
    }
  }
}
