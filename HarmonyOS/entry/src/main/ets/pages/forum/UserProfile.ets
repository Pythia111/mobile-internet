@Entry
@Component
export default struct UserProfile {
	build() {
		Column() {
			Text('用户主页')
				.fontSize(20)
				.fontColor('#333333')
				.margin({ top: 20, left: 20 })
			// 简单占位，后续补充用户信息和帖子列表
		}
		.width('100%')
		.height('100%')
		.backgroundColor('#FFFFFF')
	}
}
