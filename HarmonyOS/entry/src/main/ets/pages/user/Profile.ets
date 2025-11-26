import router from '@ohos.router';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';

interface UserInfo {
  username: string;
  phone: string;
  avatar: string;
}

@Component
export default struct Profile {
  @State userInfo: UserInfo = {
    username: '用户名',
    phone: '138****8888',
    avatar: ''
  };

  aboutToAppear() {
    // 检查用户是否已登录
    const token = TokenManager.getToken();
    if (!token) {
      // 如果是Tab页，这里跳转可能会有问题，最好在Index页统一处理
      return;
    }
    
    // 这里可以调用API获取用户信息
    // 暂时使用模拟数据
    this.loadUserInfo();
  }

  loadUserInfo() {
    // 模拟加载用户信息
    // 实际项目中应该调用API获取用户信息
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
