import router from '@ohos.router';
import RouterManager from '../../router/RouterManager';
import { Comment } from '../../model/api/ForumApi';

@Entry
@Component
struct PostComment {
  @State comments: Comment[] = [];

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['comments']) {
      this.comments = params['comments'] as Comment[];
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('<') // 假设有返回图标
          .fontSize(24)
          .fontColor('#333333')
          .margin({ right: 16 })
          .onClick(() => {
            RouterManager.goBack();
          })

        Text('查看评论')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          
        // 占位，保持标题居中
        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // 评论列表
      List() {
        ForEach(this.comments, (comment: Comment) => {
          ListItem() {
            Row() {
              // 头像
              Image(comment.avatar || $r('app.media.layered_image'))
                .width(40)
                .height(40)
                .borderRadius(20)
                .margin({ right: 12 })
                .backgroundColor('#E0E0E0')

              // 内容区域
              Column() {
                Text(comment.username)
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 4 })
                
                Text(comment.content)
                  .fontSize(16)
                  .fontColor('#333333')
                  .lineHeight(22)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .alignItems(VerticalAlign.Top)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 1, color: '#F5F5F5' })
      
      if (this.comments.length === 0) {
        Column() {
          Text('暂无评论')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 100 })
        }
        .width('100%')
        .height('100%')
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
