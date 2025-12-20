import router from '@ohos.router';
import { DietMain } from './DietMain';
import { DietSearch } from './DietSearch';
import { DietHistory } from './DietHistory';

@Entry
@Component
export default struct DietHome {
  @State currentTabIndex: number = 0;
  @Provide('refreshTrigger') refreshTrigger: number = 0;

  build() {
    Column() {
      // 顶部Tab导航
      Tabs({ index: this.currentTabIndex }) {
        TabContent() {
          DietMain()
        }
        .tabBar('饮食记录')

        TabContent() {
          DietSearch()
        }
        .tabBar('搜索食物')

        TabContent() {
          DietHistory()
        }
        .tabBar('历史记录')
      }
      .barMode(BarMode.Fixed)
      .barHeight(56)
      .animationDuration(300)
      .onChange((index: number) => {
        console.log(`DietHome: Tab切换到 ${index}`);
        this.currentTabIndex = index;
        // 触发子组件刷新
        this.refreshTrigger++;
      })
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
