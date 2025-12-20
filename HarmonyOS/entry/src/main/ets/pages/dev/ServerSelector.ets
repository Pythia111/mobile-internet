// pages/dev/ServerSelector.ets
import { ApiConfig } from '../../config/ApiConfig';
import http from '@ohos.net.http';

interface ServerStatus {
  url: string;
  status: 'testing' | 'success' | 'failed';
  message: string;
  responseTime?: number;
}

@Entry
@Component
export struct ServerSelector {
  @State servers: ServerStatus[] = [];
  @State isTesting: boolean = false;
  @State selectedIndex: number = 0;

  aboutToAppear() {
    this.initServers();
  }

  initServers() {
    const addresses = ApiConfig.getAllAddresses();
    this.servers = addresses.map((url, index) => ({
      url: url,
      status: index === 0 ? 'testing' : 'failed',
      message: index === 0 ? '当前使用' : '未测试'
    }));
    this.selectedIndex = 0;
  }

  async testServer(index: number) {
    const server = this.servers[index];
    this.servers[index] = { ...server, status: 'testing', message: '测试中...' };

    const startTime = Date.now();
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(`${server.url}/actuator/health`, {
        method: http.RequestMethod.GET,
        connectTimeout: 5000,
        readTimeout: 5000
      });

      const responseTime = Date.now() - startTime;

      if (response.responseCode === 200) {
        this.servers[index] = {
          ...server,
          status: 'success',
          message: `连接成功 (${responseTime}ms)`,
          responseTime: responseTime
        };
      } else {
        this.servers[index] = {
          ...server,
          status: 'failed',
          message: `HTTP ${response.responseCode}`
        };
      }
    } catch (error) {
      const errorMsg = error.message || 'Connection timeout';
      this.servers[index] = {
        ...server,
        status: 'failed',
        message: errorMsg
      };
    } finally {
      httpRequest.destroy();
    }
  }

  async testAllServers() {
    this.isTesting = true;
    for (let i = 0; i < this.servers.length; i++) {
      await this.testServer(i);
    }
    this.isTesting = false;
  }

  selectServer(index: number) {
    this.selectedIndex = index;
    ApiConfig.setBaseUrl(this.servers[index].url);
    console.info(`ServerSelector: 已选择服务器 ${this.servers[index].url}`);
  }

  build() {
    Column() {
      // 标题
      Text('服务器选择')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      Text('当前IP地址列表，请选择可用的服务器')
        .fontSize(14)
        .fontColor('#666')
        .margin({ bottom: 20 })

      // 测试所有按钮
      Button('测试所有服务器')
        .width('90%')
        .height(45)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .enabled(!this.isTesting)
        .onClick(() => {
          this.testAllServers();
        })
        .margin({ bottom: 20 })

      // 服务器列表
      List({ space: 10 }) {
        ForEach(this.servers, (server: ServerStatus, index: number) => {
          ListItem() {
            this.ServerCard(server, index)
          }
        }, (server: ServerStatus) => server.url)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 20, right: 20 })

      // 说明文字
      Column() {
        Text('提示：')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 5 })
        Text('• 绿色表示连接成功')
          .fontSize(12)
          .fontColor('#666')
        Text('• 红色表示连接失败')
          .fontSize(12)
          .fontColor('#666')
        Text('• 选择响应时间最短的服务器')
          .fontSize(12)
          .fontColor('#666')
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ top: 10, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }

  @Builder ServerCard(server: ServerStatus, index: number) {
    Column() {
      Row() {
        // 状态指示器
        Circle({ width: 12, height: 12 })
          .fill(this.getStatusColor(server.status))
          .margin({ right: 10 })

        Column() {
          Text(server.url)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
          Text(server.message)
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 操作按钮
        if (server.status !== 'testing') {
          Row({ space: 5 }) {
            Button('测试')
              .fontSize(12)
              .width(50)
              .height(30)
              .backgroundColor('#2196F3')
              .onClick(() => {
                this.testServer(index);
              })

            if (server.status === 'success') {
              Button(this.selectedIndex === index ? '已选' : '选择')
                .fontSize(12)
                .width(50)
                .height(30)
                .backgroundColor(this.selectedIndex === index ? '#999' : '#4CAF50')
                .enabled(this.selectedIndex !== index)
                .onClick(() => {
                  this.selectServer(index);
                })
            }
          }
        } else {
          LoadingProgress()
            .width(30)
            .height(30)
        }
      }
      .width('100%')
      .padding(15)
    }
    .width('100%')
    .backgroundColor(this.selectedIndex === index ? '#E8F5E9' : '#FFFFFF')
    .borderRadius(8)
    .border({
      width: 2,
      color: this.selectedIndex === index ? '#4CAF50' : '#E0E0E0'
    })
  }

  getStatusColor(status: string): ResourceColor {
    switch (status) {
      case 'success':
        return '#4CAF50';
      case 'failed':
        return '#F44336';
      case 'testing':
        return '#FFC107';
      default:
        return '#999999';
    }
  }
}
