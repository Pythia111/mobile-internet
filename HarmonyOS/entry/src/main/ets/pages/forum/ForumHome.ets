import router from '@ohos.router';
import { getPosts, Post } from '../../model/api/ForumApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
export default struct ForumHome {
  @State posts: Post[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.loadPosts();
  }

  async loadPosts() {
    this.isLoading = true;
    try {
      const response = await getPosts();
      if (response.code === 200) {
        this.posts = response.data.posts;
      } else {
        promptAction.showToast({
          message: response.message || '加载失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Load posts failed:', error);
      // 模拟数据用于展示
      this.posts = [
        {
          postId: '1',
          title: '健康饮食分享',
          userId: '1',
          username: 'User1',
          images: ['app.media.layered_image'], // 使用本地资源作为占位
          avatar: '',
          status: 0,
          likeCount: 10
        },
        {
          postId: '2',
          title: '今日减脂餐',
          userId: '2',
          username: 'User2',
          images: [],
          avatar: '',
          status: 0,
          likeCount: 5
        },
        {
          postId: '3',
          title: '运动打卡',
          userId: '3',
          username: 'User3',
          images: [],
          avatar: '',
          status: 0,
          likeCount: 8
        }
      ];
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        // 顶部标题
        Text('社区')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .width('100%')
          .padding({ left: 20, top: 20, bottom: 10 })
          .backgroundColor('#FFFFFF')

        // 帖子列表
        Grid() {
          ForEach(this.posts, (post: Post) => {
            GridItem() {
              Column() {
                // 帖子图片
                if (post.images && post.images.length > 0) {
                  Image(post.images[0])
                    .width('100%')
                    .height(150)
                    .objectFit(ImageFit.Cover)
                    .borderRadius({ topLeft: 8, topRight: 8 })
                    .backgroundColor('#F0F0F0')
                } else {
                  Column() {
                    Image($r('app.media.layered_image'))
                      .width(40)
                      .height(40)
                      .opacity(0.5)
                  }
                  .width('100%')
                  .height(150)
                  .backgroundColor('#F5F5F5')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .borderRadius({ topLeft: 8, topRight: 8 })
                }

                // 帖子标题
                Text(post.title)
                  .fontSize(14)
                  .fontColor('#333333')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .padding(10)
                  .width('100%')
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .shadow({ radius: 4, color: '#00000010', offsetY: 2 })
              .onClick(() => {
                this.navigateToDetail(post);
              })
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .padding(10)
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 发布按钮
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        Text('+')
          .fontSize(30)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Lighter)
      }
      .width(60)
      .height(60)
      .backgroundColor('#4CAF50')
      .margin({ right: 20, bottom: 30 })
      .shadow({ radius: 6, color: '#4CAF5060', offsetY: 4 })
      .onClick(() => {
        router.pushUrl({
          url: 'pages/forum/CreatePost'
        });
      })
    }
    .width('100%')
    .height('100%')
  }

  // 跳转到帖子详情
  navigateToDetail(post: Post) {
    let params: Record<string, Object> = {
      'postId': post.postId
    };
    router.pushUrl({
      url: 'pages/forum/PostDetail',
      params: params
    });
  }
}
