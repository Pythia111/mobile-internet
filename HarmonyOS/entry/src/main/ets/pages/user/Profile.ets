import router from '@ohos.router';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';
import RouterManager from '../../router/RouterManager';
import { getUserProfile } from '../../model/api/UserApi';
import { getMyPosts, Post } from '../../model/api/ForumApi';

interface UserInfo {
  username: string;
  phone: string;
  avatar: string;
}

interface PostDetailParams {
  postId: string;
}

@Entry
@Component
export default struct Profile {
  @State userInfo: UserInfo = {
    username: '用户名',
    phone: '138****8888',
    avatar: ''
  };
  @State myPosts: Post[] = [];
  @State isLoading: boolean = false;
  @State isPageActive: boolean = true;

  aboutToAppear() {
    // 检查用户是否已登录
    this.checkLogin();
    // 加载用户信息
    this.loadUserInfo();
    this.loadMyPosts();
  }

  aboutToDisappear() {
    this.isPageActive = false;
  }

  onPageShow() {
    this.loadUserInfo();
    this.loadMyPosts();
  }

  async checkLogin() {
    const hasToken = await TokenManager.hasToken();
    if (!hasToken) {
      // 如果未登录，可以在这里处理，或者在Index页统一处理
    }
  }

  async loadUserInfo() {
    try {
      const response = await getUserProfile();
      if (response.code === 200 && response.data) {
        this.userInfo = {
          username: response.data.username,
          phone: response.data.phone,
          avatar: response.data.avatar
        };
      }
    } catch (e) {
      console.error('Load user info failed', e);
    }
  }

  async loadMyPosts() {
    this.isLoading = true;
    try {
      const response = await getMyPosts();
      if (response.code === 200 && response.data) {
        // 过滤掉已删除(status=3)的帖子
        this.myPosts = response.data.filter(p => p.status !== 3);
      }
    } catch (e) {
      console.error('Load my posts failed', e);
    } finally {
      this.isLoading = false;
    }
  }

  // 退出登录
  async handleLogout() {
    try {
      await TokenManager.clear();
      
      if (!this.isPageActive) return;

      const uiContext = this.getUIContext();
      const routerInstance = uiContext?.getRouter();
      const prompt = uiContext?.getPromptAction();

      // 尝试直接调用 UI 操作
      try {
        if (prompt) {
          prompt.showToast({ message: '已退出登录', duration: 2000 });
        }
        if (routerInstance) {
          routerInstance.replaceUrl({ url: 'pages/auth/Login' });
        }
      } catch (e) {
        console.warn('Direct UI operation failed', e);
      }
    } catch (error) {
      console.error('Logout failed:', error);
      try { 
        const uiContext = this.getUIContext();
        const prompt = uiContext?.getPromptAction();
        if (prompt) prompt.showToast({ message: '退出失败', duration: 2000 }); 
      } catch (e) {}
    }
  }

  build() {
    Column() {
      // 顶部用户信息区域
      Column() {
        Row() {
          // 头像
          if (this.userInfo.avatar && this.userInfo.avatar !== 'default_avatar') {
            Image(this.userInfo.avatar)
              .width(80)
              .height(80)
              .borderRadius(40)
              .objectFit(ImageFit.Cover)
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
      Column() {
        Row() {
          Text('我的帖子')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          
          // 刷新按钮
          Button('刷新')
            .fontSize(12)
            .fontColor('#4CAF50')
            .backgroundColor('transparent')
            .border({ width: 1, color: '#4CAF50', radius: 4 })
            .height(28)
            .onClick(() => {
              this.loadMyPosts();
            })
        }
        .width('100%')
        .margin({ bottom: 10 })

        if (this.isLoading) {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 20 })
        } else if (this.myPosts.length === 0) {
          Column() {
            Text('暂无帖子')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 20 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        } else {
          Grid() {
            ForEach(this.myPosts, (post: Post) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  // 帖子图片（取第一张或默认）
                  Image(post.images && post.images.length > 0 ? post.images[0] : '')
                    .width('100%')
                    .height(120)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                    .backgroundColor('#F5F5F5')

                  // 待审核标签
                  if (post.status === 1) {
                    Text('待审核')
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FF9800')
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius({ bottomLeft: 8, topRight: 8 })
                  }

                  // 标题遮罩
                  Row() {
                    Text(post.title)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width('100%')
                  .padding(6)
                  .backgroundColor('#00000060')
                  .borderRadius({ bottomLeft: 8, bottomRight: 8 })
                  .position({ x: 0, y: 94 }) // 120 - 26 approx
                }
                .width('100%')
                .height(120)
                .onClick(() => {
                  const params: PostDetailParams = { postId: post.postId };
                  RouterManager.navigateTo('pages/forum/PostDetail', params);
                })
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)
      .alignItems(HorizontalAlign.Start)

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
