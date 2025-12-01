import router from '@ohos.router';
import { getPosts, Post } from '../../model/api/ForumApi';
import RouterManager from '../../router/RouterManager';
import promptAction from '@ohos.promptAction';

interface RouteParams {
	userId?: string;
	username?: string;
	avatar?: string;
}

interface PostDetailParams {
  postId: string;
}

@Entry
@Component
export default struct UserProfile {
	@State userId: string = '';
	@State username: string = '用户';
	@State avatar: string = '';
	@State posts: Post[] = [];
	@State isLoading: boolean = false;

	aboutToAppear() {
		try {
			const params = router.getParams() as RouteParams;
			if (params) {
				if (params.userId) this.userId = params.userId;
				if (params.username) this.username = params.username;
				if (params.avatar) this.avatar = params.avatar;
			}
		} catch (e) {
			console.warn('UserProfile: getParams failed', e);
		}
		this.loadUserPosts();
	}

	async loadUserPosts() {
		this.isLoading = true;
		try {
			const resp = await getPosts(0); // 获取公开帖子
			if (resp.code === 200 && resp.data && resp.data.posts) {
				// 过滤出指定 userId 的公开帖子
				this.posts = resp.data.posts.filter((p: Post) => p.userId === this.userId && p.status === 0);
			}
		} catch (e) {
			console.error('Load user posts failed', e);
			try { promptAction.showToast({ message: '加载用户帖子失败', duration: 2000 }); } catch (e) {}
		} finally {
			this.isLoading = false;
		}
	}

	navigateToPost(postId: string) {
		const params: PostDetailParams = { postId: postId };
		RouterManager.navigateTo('pages/forum/PostDetail', params);
	}

	build() {
		Column() {
			// 顶部导航栏
			Row() {
				Text('<')
					.fontSize(24)
					.fontWeight(FontWeight.Regular)
					.padding({ left: 16, right: 16, top: 12, bottom: 12 })
					.onClick(() => {
						router.back();
					})
				Text('用户主页')
					.fontSize(18)
					.fontWeight(FontWeight.Medium)
					.layoutWeight(1)
			}
			.width('100%')
			.backgroundColor('#FFFFFF')
			.alignItems(VerticalAlign.Center)

			// 头部用户信息
			Column() {
				Row() {
					// 头像
					if (this.avatar) {
						Image(this.avatar)
							.width(80)
							.height(80)
							.borderRadius(12)
							.objectFit(ImageFit.Cover)
					} else {
						Circle({ width: 80, height: 80 })
							.fill('#E0E0E0')
						Text('头像')
							.fontSize(14)
							.fontColor('#999999')
					}

					Column() {
						Text(this.username)
							.fontSize(20)
							.fontWeight(FontWeight.Medium)
							.fontColor('#333333')
						Text('用户主页')
							.fontSize(12)
							.fontColor('#999999')
					}
					.margin({ left: 16 })

					Blank()


				}
				.width('100%')
				.padding({ left: 20, right: 20, top: 24, bottom: 20 })
				.backgroundColor('#FFFFFF')
			}

			// 帖子列表（只显示公开）
			Column() {
				Row() {
					Text('用户的公开帖子')
						.fontSize(18)
						.fontWeight(FontWeight.Bold)
						.layoutWeight(1)

					Button('刷新')
						.fontSize(12)
						.fontColor('#4CAF50')
						.backgroundColor('transparent')
						.border({ width: 1, color: '#4CAF50', radius: 4 })
						.height(28)
						.onClick(() => { this.loadUserPosts(); })
				}
				.width('100%')
				.padding({ left: 20, right: 20, top: 12, bottom: 12 })

				if (this.isLoading) {
					Text('加载中...')
						.fontSize(14)
						.fontColor('#999999')
						.margin({ top: 20 })
				} else if (this.posts.length === 0) {
					Column() {
						Text('该用户暂无公开帖子')
							.fontSize(14)
							.fontColor('#999999')
							.margin({ top: 20 })
					}
					.width('100%')
					.alignItems(HorizontalAlign.Center)
				} else {
					Grid() {
						ForEach(this.posts, (post: Post) => {
							GridItem() {
								Stack({ alignContent: Alignment.BottomStart }) {
									Image(post.images && post.images.length > 0 ? post.images[0] : '')
										.width('100%')
										.height(120)
										.objectFit(ImageFit.Cover)
										.borderRadius(8)
										.backgroundColor('#F5F5F5')

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
								}
								.width('100%')
								.height(120)
								.onClick(() => { this.navigateToPost(post.postId); })
							}
						})
					}
					.columnsTemplate('1fr 1fr')
					.columnsGap(10)
					.rowsGap(10)
					.padding({ left: 16, right: 16 })
				}
			}
			.layoutWeight(1)
			.width('100%')
		}
		.width('100%')
		.height('100%')
		.backgroundColor('#FFFFFF')
	}
}
