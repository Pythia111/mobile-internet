import router from '@ohos.router';
import { login } from '../../model/api/AuthApi';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State phoneError: string = '';
  @State passwordError: string = '';

  // 验证手机号
  validatePhone(phone: string): string {
    if (!phone) {
      return '请输入手机号';
    }
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(phone)) {
      return '请输入正确的手机号';
    }
    return '';
  }

  // 验证密码
  validatePassword(password: string): string {
    if (!password) {
      return '请输入密码';
    }
    if (password.length < 6) {
      return '密码至少6位';
    }
    const hasLetter = /[a-zA-Z]/.test(password);
    const hasNumber = /\d/.test(password);
    if (!hasLetter || !hasNumber) {
      return '密码必须包含字母和数字';
    }
    return '';
  }

  // 登录处理
  async handleLogin() {
    // 验证输入
    this.phoneError = this.validatePhone(this.phone);
    this.passwordError = this.validatePassword(this.password);

    if (this.phoneError || this.passwordError) {
      return;
    }

    this.isLoading = true;

    try {
      const response = await login(this.phone, this.password);
      
      if (response.code === 200) {
        // 保存token
        TokenManager.setToken(response.data.token);
        
        promptAction.showToast({
          message: '登录成功',
          duration: 2000
        });

        // 跳转到主页
        router.pushUrl({
          url: 'pages/Index'
        });
      } else {
        promptAction.showToast({
          message: response.message || '登录失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('登录错误:', error);
      promptAction.showToast({
        message: '网络错误，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到注册页面
  goToRegister() {
    router.pushUrl({
      url: 'pages/auth/Register'
    });
  }

  build() {
    Column() {
      // 标题
      Text('饮食记录')
        .fontSize(32)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ top: 80, bottom: 60 })

      // 登录表单
      Column() {
        // 手机号输入框
        Column() {
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .height(50)
            .fontSize(16)
            .fontColor('#333333')
            .backgroundColor('#FFFFFF')
            .border({
              width: 1,
              color: this.phoneError ? '#FF4444' : '#E5E5E5',
              radius: 8
            })
            .placeholderColor('#999999')
            .onChange((value: string) => {
              this.phone = value;
              if (this.phoneError) {
                this.phoneError = this.validatePhone(value);
              }
            })
            .onFocus(() => {
              this.phoneError = '';
            })

          if (this.phoneError) {
            Text(this.phoneError)
              .fontSize(12)
              .fontColor('#FF4444')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 密码输入框
        Column() {
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .height(50)
            .fontSize(16)
            .fontColor('#333333')
            .backgroundColor('#FFFFFF')
            .border({
              width: 1,
              color: this.passwordError ? '#FF4444' : '#E5E5E5',
              radius: 8
            })
            .placeholderColor('#999999')
            .onChange((value: string) => {
              this.password = value;
              if (this.passwordError) {
                this.passwordError = this.validatePassword(value);
              }
            })
            .onFocus(() => {
              this.passwordError = '';
            })

          if (this.passwordError) {
            Text(this.passwordError)
              .fontSize(12)
              .fontColor('#FF4444')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 30 })

        // 注册链接
        Row() {
          Text('没有账号？')
            .fontSize(14)
            .fontColor('#666666')
          
          Text('立即注册')
            .fontSize(14)
            .fontColor('#007AFF')
            .onClick(() => {
              this.goToRegister();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 40 })

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isLoading ? '#CCCCCC' : '#007AFF')
          .border({ radius: 8 })
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })
      }
      .width('80%')
      .padding(30)
      .backgroundColor('#FFFFFF')
      .border({ radius: 12 })
      .shadow({
        radius: 10,
        color: '#00000010',
        offsetX: 0,
        offsetY: 5
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 20, right: 20 })
  }
}