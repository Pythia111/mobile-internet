import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export default class TokenManager {
  private static readonly PREFERENCES_NAME = 'user_preferences';
  private static readonly TOKEN_KEY = 'user_token';
  private static preferencesInstance: preferences.Preferences | null = null;

  // 初始化preferences
  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!TokenManager.preferencesInstance) {
      try {
        const context = getContext() as common.UIAbilityContext;
        TokenManager.preferencesInstance = await preferences.getPreferences(context, TokenManager.PREFERENCES_NAME);
        console.info('TokenManager: Preferences初始化成功');
      } catch (error) {
        console.error('TokenManager: Preferences初始化失败', JSON.stringify(error));
        throw new Error('Preferences初始化失败');
      }
    }
    return TokenManager.preferencesInstance;
  }

  // 设置token
  static async setToken(token: string): Promise<void> {
    try {
      const prefs = await TokenManager.getPreferences();
      await prefs.put(TokenManager.TOKEN_KEY, token);
      await prefs.flush();
      console.info('TokenManager: Token保存成功');
    } catch (error) {
      console.error('TokenManager: Token保存失败', JSON.stringify(error));
    }
  }

  // 获取token
  static async getToken(): Promise<string | null> {
    try {
      const prefs = await TokenManager.getPreferences();
      const token = await prefs.get(TokenManager.TOKEN_KEY, '') as string;
      console.info('TokenManager: Token获取', token ? '成功' : '为空');
      return token || null;
    } catch (error) {
      console.error('TokenManager: Token获取失败', JSON.stringify(error));
      return null;
    }
  }

  // 清除token
  static async clear(): Promise<void> {
    try {
      const prefs = await TokenManager.getPreferences();
      await prefs.delete(TokenManager.TOKEN_KEY);
      await prefs.flush();
      console.info('TokenManager: Token清除成功');
    } catch (error) {
      console.error('TokenManager: Token清除失败', JSON.stringify(error));
    }
  }

  // 检查token是否存在
  static async hasToken(): Promise<boolean> {
    const token = await TokenManager.getToken();
    return token !== null && token.length > 0;
  }
}
