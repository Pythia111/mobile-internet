import router from '@ohos.router';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';
import RouterManager from '../../router/RouterManager';

interface UserInfo {
  username: string;
  phone: string;
  avatar: string;
}

@Entry
@Component
export default struct Profile {
  @State userInfo: UserInfo = {
    username: '用户名',
    phone: '138****8888',
    avatar: ''
  };

  aboutToAppear() {
    // 检查用户是否已登录
    this.checkLogin();
    // 加载用户信息
    this.loadUserInfo();
  }

  async checkLogin() {
    const hasToken = await TokenManager.hasToken();
    if (!hasToken) {
      // 如果未登录，可以在这里处理，或者在Index页统一处理
    }
  }

  loadUserInfo() {
    // 模拟加载用户信息
    // 实际项目中应该调用API获取用户信息
  }

  // 退出登录
  async handleLogout() {
    try {
      await TokenManager.clear();
      promptAction.showToast({
        message: '已退出登录',
        duration: 2000
      });
      
      // 跳转到登录页（使用 RouterManager 以保证跨平台兼容）
      RouterManager.goToLogin();
    } catch (error) {
      console.error('Logout failed:', error);
      promptAction.showToast({
        message: '退出失败',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 顶部用户信息区域
      Column() {
        Row() {
          // 头像
          if (this.userInfo.avatar) {
            Image(this.userInfo.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
          } else {
            Stack({ alignContent: Alignment.Center }) {
              Circle({ width: 80, height: 80 })
                .fill('#FFFFFF')
                .border({ width: 1, color: '#E0E0E0' })
              Text('头像')
                .fontSize(14)
                .fontColor('#999999')
            }
          }
          
          // 用户名
          Text(this.userInfo.username)
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 20 })
            
          Blank()
          
          // 编辑资料按钮
          Button('编辑资料')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor('#999999')
            .height(28)
            .borderRadius(14)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/user/EditProfile'
              });
            })
        }
        .width('100%')
        .padding({ left: 30, right: 30, top: 40, bottom: 40 })
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 我的帖子区域
      Row() {
        // 帖子1
        Column() {
          Text('我的帖子1')
            .fontSize(18)
            .fontColor('#333333')
        }
        .width('45%')
        .height(200)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        // 帖子2
        Column() {
          Text('我的帖子2')
            .fontSize(18)
            .fontColor('#333333')
        }
        .width('45%')
        .height(200)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#E0E0E0', radius: 8 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(20)
      .margin({ top: 20 })

      Blank()

      // 退出登录按钮
      Button('退出登录')
        .width('90%')
        .height(50)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF4444')
        .margin({ bottom: 30 })
        .borderRadius(25)
        .onClick(() => {
          this.handleLogout();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
