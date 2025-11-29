import router from '@ohos.router';
import TokenManager from '../utils/TokenManager';
import DietHome from './diet/DietHome';
import Profile from './user/Profile';
import ForumHome from './forum/ForumHome';

@Entry
@Component
struct Index {
  @State currentIndex: number = 1; // 默认选中"饮食记录" (中间)
  private controller: TabsController = new TabsController();

  async aboutToAppear() {
    // 检查用户是否已登录
    const hasToken = await TokenManager.hasToken();
    if (!hasToken) {
      router.pushUrl({
        url: 'pages/auth/Login'
      });
    } else {
      // 确保初始选中饮食记录
      this.currentIndex = 1;
      this.controller.changeIndex(1);
    }
  }

  @Builder TabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#2E7D32' : '#999999')
        .fontSize(16)
        .fontWeight(this.currentIndex === targetIndex ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.controller.changeIndex(this.currentIndex);
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
      // 社区 Tab
      TabContent() {
        ForumHome()
      }
      .tabBar(this.TabBuilder('社区', 0))

      // 饮食记录 Tab
      TabContent() {
        DietHome()
      }
      .tabBar(this.TabBuilder('饮食记录', 1))

      // 我 Tab
      TabContent() {
        Profile()
      }
      .tabBar(this.TabBuilder('我', 2))
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
}