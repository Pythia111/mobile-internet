import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { getPostDetail, likePost, commentPost, PostDetailData, Comment, updatePostStatus } from '../../model/api/ForumApi';
import { getUserProfile } from '../../model/api/UserApi';
import RouterManager from '../../router/RouterManager';

interface UserProfileParams {
  userId: string;
  username?: string;
  avatar?: string;
}

interface PostCommentParams {
  comments: Comment[];
  postId: string; // 新增 postId 用于刷新
}

// 菜单项类型，匹配 bindMenu 所需的结构
interface MenuElementItem {
  value: string;
  action: () => void;
}

@Entry
@Component
struct PostDetail {
  @State postId: string = '';
  @State post: PostDetailData | null = null;
  @State isLoading: boolean = false;
  @State commentContent: string = '';
  @State isLiking: boolean = false;
  @State isCommenting: boolean = false;
  @State currentUserId: string = '';
  @State isCrtUserLiked: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['postId']) {
      this.postId = params['postId'] as string;
      this.loadPostDetail();
      this.loadCurrentUser();
    } else {
      promptAction.showToast({ message: '参数错误' });
      RouterManager.goBack();
    }
  }

  async loadCurrentUser() {
    try {
      const resp = await getUserProfile();
      if (resp.code === 200 && resp.data) {
        this.currentUserId = resp.data.userId;
      }
    } catch (e) {
      console.error('Load user profile failed', e);
    }
  }

  async loadPostDetail() {
    this.isLoading = true;
    try {
      const response = await getPostDetail(this.postId);
      if (response.code === 200) {
        this.post = response.data;
        this.isCrtUserLiked = response.data.isLiked || false;
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
    
    // 乐观更新：立即切换状态
    const previousLikedState = this.isCrtUserLiked;
    this.isCrtUserLiked = !this.isCrtUserLiked;
    if (this.isCrtUserLiked) {
      this.post.likeCount++;
    } else {
      this.post.likeCount--;
    }

    this.isLiking = true;
    try {
      const response = await likePost(this.postId);
      if (response.code === 200) {
        // 实际状态以服务器为准（可选，这里假设服务器逻辑一致）
        // promptAction.showToast({ message: this.isCrtUserLiked ? '点赞成功' : '已取消点赞' });
      } else {
        // 失败回滚
        this.isCrtUserLiked = previousLikedState;
        if (this.isCrtUserLiked) {
          this.post.likeCount++;
        } else {
          this.post.likeCount--;
        }
        promptAction.showToast({ message: '操作失败' });
      }
    } catch (error) {
      // 失败回滚
      this.isCrtUserLiked = previousLikedState;
      if (this.isCrtUserLiked) {
        this.post.likeCount++;
      } else {
        this.post.likeCount--;
      }
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

  async handleSetPrivate() {
    if (!this.post) return;
    try {
      const resp = await updatePostStatus(this.postId, 2);
      if (resp.code === 200) {
        promptAction.showToast({ message: '已设为私密！', duration: 1500 });
        if (this.post) this.post.status = 2;
      } else {
        promptAction.showToast({ message: resp.message || '操作失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络错误' });
    }
  }

  checkAndSetPrivate() {
    if (!this.post) return;
    if (this.post.status === 1) {
      AlertDialog.show({
        message: '审核中，不能执行该操作',
        confirm: {
          value: '确定',
          action: () => {}
        }
      });
      return;
    }
    this.handleSetPrivate();
  }

  handleSetPublic() {
    AlertDialog.show({
      message: '确定要将该帖子公开吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.confirmSetPublic();
        }
      }
    });
  }

  async confirmSetPublic() {
    if (!this.post) return;
    try {
      const resp = await updatePostStatus(this.postId, 1);
      if (resp.code === 200) {
        promptAction.showToast({ message: '已设为公开！待审核通过', duration: 1500 });
        if (this.post) this.post.status = 1;
      } else {
        promptAction.showToast({ message: resp.message || '操作失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络错误' });
    }
  }

  handleDelete() {
    AlertDialog.show({
      title: '确定删除？',
      message: '该操作不可撤销',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          this.confirmDelete();
        }
      }
    });
  }

  async confirmDelete() {
    if (!this.post) return;
    try {
      const resp = await updatePostStatus(this.postId, 3);
      if (resp.code === 200) {
        promptAction.showToast({ message: '已删除！', duration: 1500 });
        if (this.post) this.post.status = 3;
        setTimeout(() => {
          try {
            // 尝试使用 UIContext 的 router 返回，避免上下文丢失问题
            this.getUIContext().getRouter().back();
          } catch (e) {
            RouterManager.goBack();
          }
        }, 1500);
      } else {
        promptAction.showToast({ message: resp.message || '删除失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络错误' });
    }
  }

  navigateToComments() {
    if (!this.post) return;
    const params: PostCommentParams = { comments: this.post.comments, postId: this.postId };
    RouterManager.navigateTo('pages/forum/PostComment', params);
  }

  getMenuOptions(): MenuElementItem[] {
    const options: MenuElementItem[] = [];
    if (this.post && this.post.status === 2) {
      options.push({ value: '设为公开', action: (): void => { this.handleSetPublic(); } });
    } else {
      options.push({ value: '设为私密', action: (): void => { this.checkAndSetPrivate(); } });
    }
    options.push({ value: '删除帖子', action: (): void => { this.handleDelete(); } });
    return options;
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
            .onClick(() => {
              // 跳转到用户主页，传递 userId/username/avatar
              const up: UserProfileParams = { userId: this.post!.userId, username: this.post!.username, avatar: this.post!.avatar };
              RouterManager.navigateTo('pages/forum/UserProfile', up);
            })

            Column() {
              Text(this.post.username)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .onClick(() => {
                  const up2: UserProfileParams = { userId: this.post!.userId, username: this.post!.username, avatar: this.post!.avatar };
                  RouterManager.navigateTo('pages/forum/UserProfile', up2);
                })
              
              if (this.post.status === 2) {
                Text('当前帖子为私密状态')
                  .fontSize(10)
                  .fontColor('#FF9800')
                  .margin({ top: 2 })
              }
            }
            .alignItems(HorizontalAlign.Start)

            // 使用 String() 转换确保类型一致，避免因后端返回类型差异导致比较失败
            if (String(this.post.userId) === String(this.currentUserId)) {
              Blank()
              Text('...')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .padding({ left: 10, right: 10 })
                .bindMenu(this.getMenuOptions())
            }
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
              .backgroundColor('#228B22')
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
                Image(this.isCrtUserLiked ? 'https://cdn-icons-png.flaticon.com/128/2107/2107845.png' : 'https://cdn-icons-png.flaticon.com/128/1077/1077035.png')
                  .width(20)
                  .height(20)
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
                Image('https://cdn-icons-png.flaticon.com/128/1380/1380338.png') // 评论图标
                  .width(20)
                  .height(20)
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
