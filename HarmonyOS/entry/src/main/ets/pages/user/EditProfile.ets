import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import picker from '@ohos.file.picker';
import http from '@ohos.net.http';
import fs from '@ohos.file.fs';
import util from '@ohos.util';
import ApiClient from '../../model/api/ApiClient';
import { getUserProfile, updateUserProfile, UpdateProfileRequest } from '../../model/api/UserApi';
import TokenManager from '../../utils/TokenManager';
import RouterManager from '../../router/RouterManager';
import { ApiConfig } from '../../config/ApiConfig';

interface UploadApiResponse {
  code: number;
  data?: string;
  message?: string;
}

@Entry
@Component
struct EditProfile {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State avatar: string = '';
  @State isLoading: boolean = false;
  @State isPageActive: boolean = true;

  aboutToAppear() {
    this.loadUserInfo();
  }

  aboutToDisappear() {
    this.isPageActive = false;
  }

  async loadUserInfo() {
    try {
      const response = await getUserProfile();
      if (response.code === 200 && response.data) {
        this.username = response.data.username;
        this.avatar = response.data.avatar || '';
      }
    } catch (e) {
      console.error('Load user info failed', e);
    }
  }

  goBack() {
    this.getUIContext()?.getRouter()?.back();
  }

  // 选择图片
  async pickImage() {
    try {
      const dialogRes = await promptAction.showDialog({
        title: '更换头像',
        message: '预览器环境下无法打开系统相册，建议使用测试图片。',
        buttons: [
          { text: '使用测试图片', color: '#007DFF' },
          { text: '打开系统相册', color: '#333333' }
        ]
      });

      if (dialogRes.index === 0) {
        // 测试图片
        this.avatar = 'https://www.keaitupian.cn/cjpic/frombd/2/253/2139581748/1307183353.jpg';
        promptAction.showToast({ message: '已选择测试图片', duration: 1500 });
        return;
      }

      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });

      if (result && result.photoUris && result.photoUris.length > 0) {
        this.avatar = result.photoUris[0];
      }
    } catch (error) {
      console.error('Pick image failed:', error);
    }
  }

  // 上传图片
  async uploadImage(fileUri: string): Promise<string> {
    try {
      // 如果已经是网络图片，直接返回
      if (fileUri.startsWith('http')) {
        return fileUri;
      }

      const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      const boundary = '----WebKitFormBoundary' + new Date().getTime();
      const filename = 'avatar.jpg';
      const mimeType = 'image/jpeg';

      const prefix = `--${boundary}\r\n` +
        `Content-Disposition: form-data; name="file"; filename="${filename}"\r\n` +
        `Content-Type: ${mimeType}\r\n\r\n`;
      const suffix = `\r\n--${boundary}--\r\n`;

      const textEncoder = new util.TextEncoder();
      const prefixBuf = textEncoder.encode(prefix);
      const suffixBuf = textEncoder.encode(suffix);

      const totalLen = prefixBuf.byteLength + buffer.byteLength + suffixBuf.byteLength;
      const resultBuf = new Uint8Array(totalLen);
      
      resultBuf.set(prefixBuf, 0);
      resultBuf.set(new Uint8Array(buffer), prefixBuf.byteLength);
      resultBuf.set(suffixBuf, prefixBuf.byteLength + buffer.byteLength);

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
      return fileUri;
    } catch (e) {
      console.error('Upload error:', e);
      return fileUri;
    }
  }

  // 验证用户名
  validateUsername(username: string): boolean {
    if (!username || username.length < 2) {
      promptAction.showToast({
        message: '用户名至少2个字符',
        duration: 2000
      });
      return false;
    }
    return true;
  }

  // 验证密码
  validatePassword(): boolean {
    if (this.password) {
      if (this.password.length < 6) {
        promptAction.showToast({
          message: '密码至少6位',
          duration: 2000
        });
        return false;
      }
      
      const hasLetter = /[a-zA-Z]/.test(this.password);
      const hasNumber = /\d/.test(this.password);
      if (!hasLetter || !hasNumber) {
        promptAction.showToast({
          message: '密码必须包含字母和数字',
          duration: 2000
        });
        return false;
      }
      
      if (this.password !== this.confirmPassword) {
        promptAction.showToast({
          message: '两次密码输入不一致',
          duration: 2000
        });
        return false;
      }
    }
    return true;
  }

  // 保存修改
  async saveProfile() {
    if (!this.validateUsername(this.username) || !this.validatePassword()) {
      return;
    }

    this.isLoading = true;

    try {
      // 1. 上传头像
      let avatarUrl = this.avatar;
      if (this.avatar && !this.avatar.startsWith('http') && !this.avatar.startsWith('/uploads')) {
        avatarUrl = await this.uploadImage(this.avatar);
      }

      // 2. 更新资料
      const updateData: UpdateProfileRequest = {
        username: this.username,
        avatar: avatarUrl
      };
      
      if (this.password) {
        updateData.password = this.password;
      }

      const response = await updateUserProfile(updateData);
      
      if (response.code === 200) {
        if (!this.isPageActive) return;
        
        const uiContext = this.getUIContext();
        const prompt = uiContext?.getPromptAction();
        const routerInstance = uiContext?.getRouter();

        if (prompt) {
          prompt.showToast({
            message: '保存成功！',
            duration: 2000
          });
        }
        
        setTimeout(() => {
          if (this.isPageActive) {
            try {
              // 使用 RouterManager 的统一封装回到 Index 并切到“我”Tab
              RouterManager.goToIndexWithTab(2);
            } catch (e) {
              console.warn('RouterManager.goToIndexWithTab failed', e);
            }
          }
        }, 1000);
      } else {
        promptAction.showToast({
          message: response.message || '保存失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Save profile failed:', error);
      promptAction.showToast({
        message: '保存失败，请重试',
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
        Button('取消')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor('transparent')
          .onClick(() => {
            this.goBack();
          })

        Text('编辑资料')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Button(this.isLoading ? '保存中...' : '保存')
          .fontSize(16)
          .fontColor('#007AFF')
          .backgroundColor('transparent')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.saveProfile();
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 5,
        color: '#00000010',
        offsetY: 2
      })

      // 表单区域
      Column() {
        // 头像部分
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            if (this.avatar) {
              Image(this.avatar)
                .width(80)
                .height(80)
                .borderRadius(40)
                .objectFit(ImageFit.Cover)
            } else {
              Circle({ width: 80, height: 80 })
                .fill('#E0E0E0')
              Text('头像')
                .fontSize(14)
                .fontColor('#999999')
            }
          }
          .onClick(() => {
            this.pickImage();
          })
          
          Text('点击更换头像')
            .fontSize(14)
            .fontColor('#007AFF')
            .margin({ top: 10 })
            .onClick(() => {
              this.pickImage();
            })
        }
        .width('100%')
        .padding(30)
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 20 })
        .border({ radius: 12 })

        // 用户名输入
        Column() {
          Row() {
            Text('用户名')
              .fontSize(16)
              .fontColor('#333333')
              .width(80)
            
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .layoutWeight(1)
              .fontSize(16)
              .fontColor('#333333')
              .backgroundColor('transparent')
              .onChange((value: string) => {
                this.username = value;
              })
          }
          .width('100%')
          .height(50)
          .padding({ left: 20, right: 20 })
          
          Divider()
            .height(1)
            .color('#F0F0F0')
            .margin({ left: 20, right: 20 })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 20 })
        .border({ radius: 12 })

        // 密码修改
        Column() {
          Row() {
            Text('新密码')
              .fontSize(16)
              .fontColor('#333333')
              .width(80)
            
            TextInput({ placeholder: '不修改请留空' })
              .type(InputType.Password)
              .layoutWeight(1)
              .fontSize(16)
              .fontColor('#333333')
              .backgroundColor('transparent')
              .onChange((value: string) => {
                this.password = value;
              })
          }
          .width('100%')
          .height(50)
          .padding({ left: 20, right: 20 })

          Divider()
            .height(1)
            .color('#F0F0F0')
            .margin({ left: 20, right: 20 })

          Row() {
            Text('确认密码')
              .fontSize(16)
              .fontColor('#333333')
              .width(80)
            
            TextInput({ placeholder: '请再次输入密码' })
              .type(InputType.Password)
              .layoutWeight(1)
              .fontSize(16)
              .fontColor('#333333')
              .backgroundColor('transparent')
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
          }
          .width('100%')
          .height(50)
          .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .border({ radius: 12 })

        Text('密码要求：至少6位，包含字母和数字')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 10 })
          .alignSelf(ItemAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
