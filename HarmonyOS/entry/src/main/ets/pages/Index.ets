import router from '@ohos.router';
import TokenManager from '../utils/TokenManager';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Index {
  @State userToken: string = '';

  aboutToAppear() {
    // 检查用户是否已登录
    this.userToken = TokenManager.getToken() || '';
    if (!this.userToken) {
      // 如果没有token，跳转到登录页面
      router.pushUrl({
        url: 'pages/auth/Login'
      });
    }
  }

  // 退出登录
  logout() {
    TokenManager.clear();
    promptAction.showToast({
      message: '已退出登录',
      duration: 2000
    });
    router.pushUrl({
      url: 'pages/auth/Login'
    });
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('营养管理系统')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button('退出')
          .fontSize(14)
          .fontColor('#FF4444')
          .backgroundColor('#FFFFFF')
          .border({
            width: 1,
            color: '#FF4444',
            radius: 6
          })
          .onClick(() => {
            this.logout();
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 5,
        color: '#00000010',
        offsetY: 2
      })

      // 主要内容区域
      Column() {
        Text('欢迎使用营养管理系统')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ top: 40, bottom: 40 })

        // 功能模块网格
        Grid() {
          GridItem() {
            Column() {
              Text('📝')
                .fontSize(40)
                .margin({ bottom: 10 })
              Text('饮食记录')
                .fontSize(16)
                .fontColor('#333333')
            }
            .width('100%')
            .height(120)
            .backgroundColor('#E3F2FD')
            .border({ radius: 12 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              promptAction.showToast({
                message: '饮食记录模块开发中...',
                duration: 2000
              });
            })
          }

          GridItem() {
            Column() {
              Text('🍎')
                .fontSize(40)
                .margin({ bottom: 10 })
              Text('食物识别')
                .fontSize(16)
                .fontColor('#333333')
            }
            .width('100%')
            .height(120)
            .backgroundColor('#E8F5E8')
            .border({ radius: 12 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              promptAction.showToast({
                message: '食物识别模块开发中...',
                duration: 2000
              });
            })
          }

          GridItem() {
            Column() {
              Text('💬')
                .fontSize(40)
                .margin({ bottom: 10 })
              Text('营养论坛')
                .fontSize(16)
                .fontColor('#333333')
            }
            .width('100%')
            .height(120)
            .backgroundColor('#FFF3E0')
            .border({ radius: 12 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              promptAction.showToast({
                message: '论坛模块开发中...',
                duration: 2000
              });
            })
          }

          GridItem() {
            Column() {
              Text('👤')
                .fontSize(40)
                .margin({ bottom: 10 })
              Text('个人中心')
                .fontSize(16)
                .fontColor('#333333')
            }
            .width('100%')
            .height(120)
            .backgroundColor('#F3E5F5')
            .border({ radius: 12 })
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/user/Profile'
              });
            })
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr 1fr')
        .width('100%')
        .height(260)
        .columnsGap(20)
        .rowsGap(20)
        .padding(20)

        Text('更多功能敬请期待...')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 40 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}