export default class TokenManager {
  static _token: string | null = null;

  static setToken(token: string) {
    TokenManager._token = token;
  }

  static getToken(): string | null {
    return TokenManager._token;
  }

  static clear() {
    TokenManager._token = null;
  }
}
