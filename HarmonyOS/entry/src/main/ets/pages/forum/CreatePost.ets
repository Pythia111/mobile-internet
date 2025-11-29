import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
// import picker from '@ohos.file.picker';
import { createPost } from '../../model/api/ForumApi';
import TokenManager from '../../utils/TokenManager';

@Entry
@Component
struct CreatePost {
  @State title: string = '';
  @State content: string = '';
  @State images: string[] = [];
  @State isLoading: boolean = false;
  @State currentImageIndex: number = 0;
  private swiperController: SwiperController = new SwiperController();

  // 选择图片
  async pickImages() {
    promptAction.showToast({
      message: '图片选择功能暂不可用',
      duration: 2000
    });
    /*
    try {
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9
      });
      
      if (result.photoUris.length > 0) {
        // 将新选择的图片追加到现有图片列表
        this.images = [...this.images, ...result.photoUris];
      }
    } catch (error) {
      console.error('Pick image failed:', error);
      promptAction.showToast({
        message: '选择图片失败',
        duration: 2000
      });
    }
    */
  }

  // 验证输入
  validateInput(): boolean {
    const missingFields: string[] = [];
    
    if (this.images.length === 0) {
      missingFields.push('请上传图片');
    }
    if (!this.title.trim()) {
      missingFields.push('请输入帖子标题');
    }
    if (!this.content.trim()) {
      missingFields.push('请输入帖子内容');
    }

    if (missingFields.length > 0) {
      promptAction.showDialog({
        title: '提示',
        message: missingFields.join('\n'),
        buttons: [{ text: '确定', color: '#4CAF50' }]
      });
      return false;
    }
    return true;
  }

  // 发布帖子
  async handlePublish() {
    if (!this.validateInput()) {
      return;
    }

    this.isLoading = true;

    try {
      // 这里应该先上传图片获取URL，目前直接使用本地URI模拟
      // 实际开发中需要先调用文件上传接口
      
      const response = await createPost({
        title: this.title,
        content: this.content,
        images: this.images,
        creatorAvatar: 'default_avatar' // 暂时使用默认头像
      });

      if (response.code === 200) {
        promptAction.showToast({
          message: '发布成功',
          duration: 2000
        });
        router.back();
      } else {
        promptAction.showToast({
          message: response.message || '发布失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Publish post failed:', error);
      promptAction.showToast({
        message: '发布失败，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        // 返回按钮
        Row() {
          Text('<')
            .fontSize(24)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
          Text(' 返回')
            .fontSize(16)
            .fontColor('#333333')
        }
        .onClick(() => {
          router.back();
        })
        
        Text('发布帖子')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ left: 20 })
          
        Blank()
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      Scroll() {
        Column() {
          // 图片选择区域
          Column() {
            if (this.images.length > 0) {
              Stack({ alignContent: Alignment.BottomEnd }) {
                Swiper(this.swiperController) {
                  ForEach(this.images, (image: string) => {
                    Image(image)
                      .width('100%')
                      .height(300)
                      .objectFit(ImageFit.Contain)
                      .backgroundColor('#000000')
                  })
                }
                .width('100%')
                .height(300)
                .loop(false)
                .onChange((index: number) => {
                  this.currentImageIndex = index;
                })

                // 页码指示器
                Text(`${this.currentImageIndex + 1}/${this.images.length}`)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#00000080')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .borderRadius(12)
                  .margin({ right: 15, bottom: 15 })
              }
            } else {
              Column() {
                Text('点击选择图片')
                  .fontSize(20)
                  .fontColor('#999999')
                  .margin({ bottom: 10 })
                Text('支持多张图片上传')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
              }
              .width('100%')
              .height(300)
              .backgroundColor('#F5F5F5')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.pickImages();
              })
            }
          }
          .width('100%')
          .margin({ bottom: 20 })

          // 如果已有图片，显示继续添加按钮
          if (this.images.length > 0) {
            Button('继续添加图片')
              .fontSize(14)
              .fontColor('#4CAF50')
              .backgroundColor('transparent')
              .border({ width: 1, color: '#4CAF50', radius: 4 })
              .margin({ bottom: 20 })
              .onClick(() => {
                this.pickImages();
              })
          }

          // 标题输入
          TextInput({ placeholder: '输入标题...', text: this.title })
            .width('100%')
            .height(50)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#E0E0E0', radius: 4 })
            .padding({ left: 15, right: 15 })
            .margin({ bottom: 15 })
            .onChange((value: string) => {
              this.title = value;
            })

          // 内容输入
          TextArea({ placeholder: '输入帖子配文...', text: this.content })
            .width('100%')
            .height(150)
            .fontSize(16)
            .backgroundColor('#FFFFFF')
            .border({ width: 1, color: '#E0E0E0', radius: 4 })
            .padding(15)
            .margin({ bottom: 30 })
            .onChange((value: string) => {
              this.content = value;
            })

          // 发布按钮
          Button(this.isLoading ? '发布中...' : '发布')
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isLoading ? '#A5D6A7' : '#4CAF50')
            .borderRadius(25)
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handlePublish();
            })
        }
        .padding(20)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
