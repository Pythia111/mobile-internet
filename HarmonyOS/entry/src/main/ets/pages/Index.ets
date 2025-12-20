import router from '@ohos.router';
import TokenManager from '../utils/TokenManager';
import DietHome from './diet/DietHome';
import Profile from './user/Profile';
import ForumHome from './forum/ForumHome';

// 路由参数类型
interface IndexRouteParams {
  tabIndex?: number;
  tab?: string;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 1; // 默认选中"饮食记录" (中间)
  private controller: TabsController = new TabsController();

  async aboutToAppear() {
    // 检查用户是否已登录
    const hasToken = await TokenManager.hasToken();
    if (!hasToken) {
      // 使用 replaceUrl 避免返回键回到空白页
      router.replaceUrl({
        url: 'pages/auth/Login'
      });
    } else {
      // 如果有路由参数（例如从编辑资料返回时传入 tabIndex），则切换到对应 Tab
      try {
        const params = router.getParams() as IndexRouteParams;
        let handled = false;
        if (params) {
          if (params.tabIndex !== undefined && typeof params.tabIndex === 'number') {
            this.currentIndex = params.tabIndex;
            handled = true;
            // controller 可能未初始化，使用 setTimeout 确保切换
            setTimeout(() => { try { this.controller.changeIndex(this.currentIndex); } catch (e) {} }, 0);
          } else if (params.tab === 'profile') {
            this.currentIndex = 2;
            handled = true;
            setTimeout(() => { try { this.controller.changeIndex(this.currentIndex); } catch (e) {} }, 0);
          }
        }
        // 如果没有由参数处理，则保持默认或显式设置为饮食记录（1）
        if (!handled) {
          this.currentIndex = 1;
        }
      } catch (e) {
        // ignore deprecated getParams or other errors
        this.currentIndex = 1;
      }
      // 注意：aboutToAppear 中 controller 可能还未准备好，建议在 onPageShow 或 build 中处理初始状态
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