import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { getPostDetail, likePost, commentPost, PostDetailData, Comment } from '../../model/api/ForumApi';
import RouterManager from '../../router/RouterManager';

@Entry
@Component
struct PostDetail {
  @State postId: string = '';
  @State post: PostDetailData | null = null;
  @State isLoading: boolean = false;
  @State commentContent: string = '';
  @State isLiking: boolean = false;
  @State isCommenting: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['postId']) {
      this.postId = params['postId'] as string;
      this.loadPostDetail();
    } else {
      promptAction.showToast({ message: '参数错误' });
      RouterManager.goBack();
    }
  }

  async loadPostDetail() {
    this.isLoading = true;
    try {
      const response = await getPostDetail(this.postId);
      if (response.code === 200) {
        this.post = response.data;
      } else {
        promptAction.showToast({ message: response.message || '加载失败' });
      }
    } catch (error) {
      console.error('Load post detail failed:', error);
      promptAction.showToast({ message: '网络错误' });
    } finally {
      this.isLoading = false;
    }
  }

  async handleLike() {
    if (this.isLiking || !this.post) return;
    this.isLiking = true;
    try {
      const response = await likePost(this.postId);
      if (response.code === 200) {
        this.post.likeCount += 1; // 简单模拟点赞数增加
        promptAction.showToast({ message: '点赞成功' });
      }
    } catch (error) {
      promptAction.showToast({ message: '操作失败' });
    } finally {
      this.isLiking = false;
    }
  }

  async handleComment() {
    if (!this.commentContent.trim()) {
      promptAction.showToast({ message: '请输入评论内容' });
      return;
    }
    if (this.isCommenting || !this.post) return;
    
    this.isCommenting = true;
    try {
      // 这里需要获取当前用户信息，暂时模拟
      const username = '当前用户'; 
      const avatar = 'default_avatar';

      const response = await commentPost(this.postId, this.commentContent, username, avatar);
      if (response.code === 200) {
        promptAction.showToast({ message: '评论成功' });
        this.commentContent = '';
        // 刷新详情或手动添加评论到列表
        this.loadPostDetail();
      } else {
        promptAction.showToast({ message: response.message || '评论失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络错误' });
    } finally {
      this.isCommenting = false;
    }
  }

  navigateToComments() {
    if (!this.post) return;
    let params: Record<string, Object> = {
      'comments': this.post.comments
    };
    RouterManager.navigateTo('pages/forum/PostComment', params);
  }

  build() {
    Column() {
      // 1. 顶部导航栏
      Row() {
        // 返回图标
        Text('<')
          .fontSize(24)
          .fontColor('#333333')
          .margin({ right: 16 })
          .onClick(() => {
            RouterManager.goBack();
          })

        if (this.post) {
          Image(this.post.avatar || $r('app.media.layered_image')) // 默认头像
            .width(32)
            .height(32)
            .borderRadius(16)
            .margin({ right: 8 })
            .backgroundColor('#E0E0E0')

          Text(this.post.username)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 100 })
      } else if (this.post) {
        Scroll() {
          Column() {
            // 2. 图片轮播区域
            if (this.post.images && this.post.images.length > 0) {
              Swiper() {
                ForEach(this.post.images, (image: string) => {
                  Image(image)
                    .width('100%')
                    .height(300)
                    .objectFit(ImageFit.Cover)
                    .backgroundColor('#F5F5F5')
                })
              }
              .width('100%')
              .height(300)
              .indicator(true)
              .loop(false)
            }

            // 3. 标题和内容
            Column() {
              Text(this.post.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 12 })
                .width('100%')

              Text(this.post.content)
                .fontSize(16)
                .fontColor('#666666')
                .lineHeight(24)
                .width('100%')
            }
            .padding(16)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
        }
        .layoutWeight(1)
        .width('100%')

        // 4. 底部评论输入框和操作栏
        Column() {
          // 评论输入框
          Row() {
            TextInput({ placeholder: '输入评论...', text: this.commentContent })
              .layoutWeight(1)
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(20)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.commentContent = value;
              })

            Button('发送')
              .height(32)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#007AFF')
              .borderRadius(16)
              .margin({ left: 12 })
              .onClick(() => {
                this.handleComment();
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('#FFFFFF')
          .border({ width: { bottom: 1 }, color: '#F0F0F0' })

          // 5. 底部状态栏（点赞数、评论数）
          Row() {
            Blank()

            Row() {
              // 点赞
              Row() {
                Text('❤') // 替换为点赞图标
                  .fontSize(20)
                  .fontColor('#FF4444')
                  .margin({ right: 4 })
                Text(this.post.likeCount.toString())
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .onClick(() => {
                this.handleLike();
              })
              .margin({ right: 24 })

              // 评论（点击跳转）
              Row() {
                Text('💬') // 替换为评论图标
                  .fontSize(20)
                  .fontColor('#666666')
                  .margin({ right: 4 })
                Text(this.post.comments ? this.post.comments.length.toString() : '0')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .onClick(() => {
                this.navigateToComments();
              })
            }
          }
          .width('100%')
          .height(40)
          .padding({ right: 16 })
          .backgroundColor('#FFFFFF')
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
