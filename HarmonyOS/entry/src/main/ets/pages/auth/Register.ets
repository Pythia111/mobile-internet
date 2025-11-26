import router from '@ohos.router';
import { register } from '../../model/api/AuthApi';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State usernameError: string = '';
  @State phoneError: string = '';
  @State passwordError: string = '';

  // 验证用户名
  validateUsername(username: string): string {
    if (!username) {
      return '请输入用户名';
    }
    if (username.length < 2) {
      return '用户名至少2个字符';
    }
    if (username.length > 20) {
      return '用户名不能超过20个字符';
    }
    return '';
  }

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

  // 注册处理
  async handleRegister() {
    // 验证输入
    this.usernameError = this.validateUsername(this.username);
    this.phoneError = this.validatePhone(this.phone);
    this.passwordError = this.validatePassword(this.password);

    if (this.usernameError || this.phoneError || this.passwordError) {
      return;
    }

    this.isLoading = true;

    try {
      const response = await register(this.phone, this.password, this.username);
      
      if (response.code === 200) {
        // 保存token
        TokenManager.setToken(response.data.token);
        
        promptAction.showToast({
          message: '注册成功',
          duration: 2000
        });

        // 跳转到主页
        router.pushUrl({
          url: 'pages/Index'
        });
      } else {
        promptAction.showToast({
          message: response.message || '注册失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('注册错误:', error);
      promptAction.showToast({
        message: '网络错误，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 返回登录页面
  goBack() {
    router.back();
  }

  build() {
    Column() {
      // 标题
      Text('饮食记录')
        .fontSize(32)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .margin({ top: 80, bottom: 60 })

      // 注册表单
      Column() {
        // 用户名输入框
        Column() {
          TextInput({ placeholder: '请输入用户名', text: this.username })
            .height(50)
            .fontSize(16)
            .fontColor('#333333')
            .backgroundColor('#FFFFFF')
            .border({
              width: 1,
              color: this.usernameError ? '#FF4444' : '#E5E5E5',
              radius: 8
            })
            .placeholderColor('#999999')
            .onChange((value: string) => {
              this.username = value;
              if (this.usernameError) {
                this.usernameError = this.validateUsername(value);
              }
            })
            .onFocus(() => {
              this.usernameError = '';
            })

          if (this.usernameError) {
            Text(this.usernameError)
              .fontSize(12)
              .fontColor('#FF4444')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })

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
          TextInput({ placeholder: '请输入密码（字母/数字，至少6位）', text: this.password })
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
        .margin({ bottom: 40 })

        // 按钮组
        Row() {
          // 返回按钮
          Button('返回')
            .width('45%')
            .height(50)
            .fontSize(16)
            .fontColor('#007AFF')
            .backgroundColor('#FFFFFF')
            .border({ 
              width: 1,
              color: '#007AFF',
              radius: 8
            })
            .onClick(() => {
              this.goBack();
            })

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '立即注册')
            .width('45%')
            .height(50)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isLoading ? '#CCCCCC' : '#007AFF')
            .border({ radius: 8 })
            .enabled(!this.isLoading)
            .onClick(() => {
              this.handleRegister();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
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