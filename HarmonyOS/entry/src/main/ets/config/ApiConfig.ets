export class ApiConfig {
  // 可用的服务器地址列表
  private static readonly SERVER_ADDRESSES = [
    'http://localhost:8080',
    'http://192.268.142.1:8080',    // WLAN IP (主要)
    'http://192.168.254.1:8080',   // VMware Network Adapter VMnet8
    'http://10.6.1.83:8080',  // VMware Network Adapter VMnet1
    'http://172.31.176.1:8080'       // 本地回环地址
  ];

  // 当前使用的服务器地址索引
  private static currentAddressIndex = 0;

  // 获取当前API地址
  static getCurrentBaseUrl(): string {
    return ApiConfig.SERVER_ADDRESSES[ApiConfig.currentAddressIndex];
  }

  // 切换到下一个服务器地址
  static switchToNextAddress(): string {
    ApiConfig.currentAddressIndex = (ApiConfig.currentAddressIndex + 1) % ApiConfig.SERVER_ADDRESSES.length;
    console.info(`ApiConfig: 切换到服务器地址 ${ApiConfig.getCurrentBaseUrl()}`);
    return ApiConfig.getCurrentBaseUrl();
  }

  // 获取所有可用地址
  static getAllAddresses(): string[] {
    return [...ApiConfig.SERVER_ADDRESSES];
  }

  // 设置特定地址
  static setBaseUrl(address: string): void {
    const index = ApiConfig.SERVER_ADDRESSES.indexOf(address);
    if (index !== -1) {
      ApiConfig.currentAddressIndex = index;
      console.info(`ApiConfig: 手动设置服务器地址为 ${address}`);
    }
  }
}