import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import ApiClient from '../../model/api/ApiClient';
import { createPost } from '../../model/api/ForumApi';
import { getUserProfile } from '../../model/api/UserApi';
import TokenManager from '../../utils/TokenManager';
import { ApiConfig } from '../../config/ApiConfig';

interface UploadApiResponse {
  code: number;
  data?: string;
  message?: string;
}

@Entry
@Component
struct CreatePost {
  @State title: string = '';
  @State content: string = '';
  @State images: string[] = [];
  @State isLoading: boolean = false;
  @State currentImageIndex: number = 0;
  @State showSuccessMessage: boolean = false;
  @State isSuccess: boolean = false;
  @State isPageActive: boolean = true;
  private swiperController: SwiperController = new SwiperController();

  aboutToDisappear() {
    this.isPageActive = false;
    // 页面即将销毁时清理定时器
    if (this.isSuccess) {
      this.isSuccess = false;
      this.showSuccessMessage = false;
    }
  }

  // 选择图片
  async pickImages() {
    try {
      // 弹窗询问用户使用测试图片还是系统相册
      const dialogRes = await promptAction.showDialog({
        title: '选择图片方式',
        message: '预览器环境下无法打开系统相册，建议使用测试图片。',
        buttons: [
          { text: '使用测试图片', color: '#007DFF' },
          { text: '打开系统相册', color: '#333333' }
        ]
      });

      if (dialogRes.index === 0) {
        // 选项1：添加网络测试图片（无需上传，直接可用）
        const testImages = [
          'https://pic2.zhimg.com/v2-ffe7e1207e8798000251b6b334ba4223_1200x500.jpg'

        ];
        this.images = [...this.images, ...testImages];
        promptAction.showToast({ message: '已添加测试图片', duration: 1500 });
        return;
      }

      // 选项2：原有的系统相册选择逻辑
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9
      });

      if (result && result.photoUris && result.photoUris.length > 0) {
        // 追加选择的图片 URI
        this.images = [...this.images, ...result.photoUris];
      } else {
        try {
          promptAction.showToast({ message: '未选择图片', duration: 1500 });
        } catch (e) {
          console.warn('showToast failed', e);
        }
      }
    } catch (error) {
      console.error('Pick image failed:', error);
      // 忽略取消对话框的错误
      if (error.code !== undefined) {
        // 可以在这里处理其他错误
      }
    }
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
      const uploadedImageUrls: string[] = [];

      for (let i = 0; i < this.images.length; i++) {
        const uri = this.images[i];
        // 如果已经是网络地址或后端的上传路径，直接使用
        if (typeof uri === 'string' && (uri.startsWith('http') || uri.startsWith('/uploads'))) {
          uploadedImageUrls.push(uri);
          continue;
        }

        // 上传图片
        const uploadedUrl = await this.uploadImage(uri);
        uploadedImageUrls.push(uploadedUrl);
      }

      // 获取用户信息
      let creatorName = 'HarmonyOS User';
      let creatorAvatar = 'default_avatar';
      try {
        const profileResp = await getUserProfile();
        if (profileResp.code === 200 && profileResp.data) {
          creatorName = profileResp.data.username || creatorName;
          creatorAvatar = profileResp.data.avatar || creatorAvatar;
        }
      } catch (e) {
        console.warn('Get profile failed', e);
      }

      const response = await createPost({
        title: this.title,
        content: this.content,
        images: uploadedImageUrls,
        creatorName: creatorName,
        creatorAvatar: creatorAvatar
      });

      if (response.code === 200) {
        if (!this.isPageActive) return;

        const uiContext = this.getUIContext();
        const prompt = uiContext?.getPromptAction();
        const routerInstance = uiContext?.getRouter();

        try {
          if (prompt) {
            prompt.showToast({ message: '发布成功，待审核', duration: 2500 });
          }

          setTimeout(() => {
            if (this.isPageActive && routerInstance) {
              try {
                routerInstance.back();
              } catch (e) {
                console.warn('Router back failed', e);
              }
            }
          }, 2500);
        } catch (e) {
          console.warn('UI operation failed', e);
        }
      } else {
        if (!this.isPageActive) return;
        const uiContext = this.getUIContext();
        const prompt = uiContext?.getPromptAction();

        setTimeout(() => {
          try {
            if (prompt) {
              prompt.showToast({ message: response.message || '发布失败', duration: 2000 });
            }
          } catch (e) {
            console.warn('showToast failed', e);
          }
        }, 100);
      }
    } catch (error) {
      console.error('Publish post failed:', error);
      if (!this.isPageActive) return;
      const uiContext = this.getUIContext();
      const prompt = uiContext?.getPromptAction();

      setTimeout(() => {
        try {
          if (prompt) {
            prompt.showToast({ message: '发布失败，请重试', duration: 2000 });
          }
        } catch (e) {
          console.warn('showToast failed', e);
        }
      }, 10);
    } finally {
      this.isLoading = false;
    }
  }

  // 上传单张图片
  async uploadImage(fileUri: string): Promise<string> {
    try {
      // 1. 读取文件内容
      const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      // 2. 构造 Multipart 请求体
      const boundary = '----WebKitFormBoundary' + new Date().getTime();
      const filename = 'image.jpg';
      const mimeType = 'image/jpeg';

      const prefix = `--${boundary}\r\n` +
        `Content-Disposition: form-data; name="file"; filename="${filename}"\r\n` +
        `Content-Type: ${mimeType}\r\n\r\n`;
      const suffix = `\r\n--${boundary}--\r\n`;

      const textEncoder = new util.TextEncoder();
      const prefixBuf = textEncoder.encode(prefix);
      const suffixBuf = textEncoder.encode(suffix);

      // 拼接 ArrayBuffer
      const totalLen = prefixBuf.byteLength + buffer.byteLength + suffixBuf.byteLength;
      const resultBuf = new Uint8Array(totalLen);

      resultBuf.set(prefixBuf, 0);
      resultBuf.set(new Uint8Array(buffer), prefixBuf.byteLength);
      resultBuf.set(suffixBuf, prefixBuf.byteLength + buffer.byteLength);

      // 3. 发送请求
      const url = ApiConfig.getCurrentBaseUrl() + '/api/upload/image';
      const httpRequest = http.createHttp();

      const token = await TokenManager.getToken();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
          'Authorization': token ? `Bearer ${token}` : ''
        },
        extraData: resultBuf.buffer
      });

      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as UploadApiResponse;
        if (result.code === 200 && result.data) {
          return result.data;
        }
      }
      console.error('Upload failed:', response.result);
      return fileUri;
    } catch (e) {
      console.error('Upload error:', e);
      return fileUri;
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
                  .padding({
                    left: 10,
                    right: 10,
                    top: 4,
                    bottom: 4
                  })
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

          // 成功提示覆盖层
          if (this.showSuccessMessage) {
            Stack({ alignContent: Alignment.Center }) {
              Column() {
                Text('发布成功，待审核')
                  .fontSize(18)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 10 })
                Text('3秒后自动返回')
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .opacity(0.8)
              }
              .width(220)
              .height(100)
              .backgroundColor('#4CAF50')
              .borderRadius(12)
              .onClick(() => {
                // 点击覆盖层可以提前返回
                this.showSuccessMessage = false;
                const uiContext = this.getUIContext();
                const routerInstance = uiContext?.getRouter();

                setTimeout(() => {
                  try {
                    if (routerInstance) {
                      routerInstance.back();
                    }
                  } catch (e) {
                    console.warn('Manual navigation failed', e);
                  }
                }, 100);
              })
            }
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
  }
}