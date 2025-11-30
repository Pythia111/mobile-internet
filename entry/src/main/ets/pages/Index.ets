// pages/Index.ets
import { DietMain } from './DietMain';
import { DietSearch } from './DietSearch';
import { DietHistory } from './DietHistory';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;

  build() {
    Column() {
      // 主内容区 - 使用条件渲染替代 Stack
      if (this.currentTab === 0) {
        DietMain()
          .layoutWeight(1)
      } else if (this.currentTab === 1) {
        DietSearch()
          .layoutWeight(1)
      } else if (this.currentTab === 2) {
        DietHistory()
          .layoutWeight(1)
      }

      // 底部导航栏
      Row() {
        // 首页按钮
        Column() {
          Text('🏠')
            .fontSize(20)
          Text('首页')
            .fontSize(12)
            .fontColor(this.currentTab === 0 ? '#4CAF50' : Color.Gray)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 0;
        })

        // 搜索按钮
        Column() {
          Text('🔍')
            .fontSize(20)
          Text('搜索')
            .fontSize(12)
            .fontColor(this.currentTab === 1 ? '#4CAF50' : Color.Gray)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 1;
        })

        // 历史按钮
        Column() {
          Text('📊')
            .fontSize(20)
          Text('历史')
            .fontSize(12)
            .fontColor(this.currentTab === 2 ? '#4CAF50' : Color.Gray)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 2;
        })
      }
      .width('100%')
      .height(60)
      .padding(10)
      .backgroundColor(Color.White)
      .shadow({ radius: 5, color: '#000000', offsetX: 0, offsetY: -2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}