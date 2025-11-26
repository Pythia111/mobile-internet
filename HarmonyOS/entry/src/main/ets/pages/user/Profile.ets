import router from '@ohos.router';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Profile {
  @State userInfo: any = {
    username: '用户名',
    phone: '138****8888',
    avatar: ''
  };

  aboutToAppear() {
    // 检查用户是否已登录
    const token = TokenManager.getToken();
    if (!token) {
      router.pushUrl({
        url: 'pages/auth/Login'
      });
      return;
    }
    
    // 这里可以调用API获取用户信息
    // 暂时使用模拟数据
    this.loadUserInfo();
  }

  loadUserInfo() {
    // 模拟加载用户信息
    // 实际项目中应该调用API获取用户信息
    promptAction.showToast({
      message: '加载用户信息...',
      duration: 1000
    });
  }

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

  goBack() {
    router.back();
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor('transparent')
          .onClick(() => {
            this.goBack();
          })

        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Button('编辑')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor('transparent')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/user/EditProfile'
            });
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 5,
        color: '#00000010',
        offsetY: 2
      })

      // 用户信息区域
      Column() {
        // 头像区域
        Column() {
          if (this.userInfo.avatar) {
            Image(this.userInfo.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
          } else {
            // 默认头像
            Circle({ width: 80, height: 80 })
              .fill('#E0E0E0')
              .overlay(
                Text('头像')
                  .fontSize(14)
                  .fontColor('#999999')
              )
          }
          
          Text(this.userInfo.username)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ top: 15 })
          
          Text(this.userInfo.phone)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 5 })
        }
        .width('100%')
        .padding(40)
        .backgroundColor('#FFFFFF')
        .margin({ top: 20, bottom: 20 })
        .border({ radius: 12 })

        // 功能列表
        Column() {
          // 编辑资料
          Row() {
            Text('编辑资料')
              .fontSize(16)
              .fontColor('#333333')
            
            Text('>')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height(50)
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/user/EditProfile'
            });
          })

          Divider()
            .height(1)
            .color('#F0F0F0')

          // 设置
          Row() {
            Text('设置')
              .fontSize(16)
              .fontColor('#333333')
            
            Text('>')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height(50)
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            promptAction.showToast({
              message: '设置功能开发中...',
              duration: 2000
            });
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ radius: 12 })
        .margin({ bottom: 20 })

        // 退出登录按钮
        Button('退出登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#FF4444')
          .backgroundColor('#FFFFFF')
          .border({
            width: 1,
            color: '#FF4444',
            radius: 8
          })
          .onClick(() => {
            this.logout();
          })
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
