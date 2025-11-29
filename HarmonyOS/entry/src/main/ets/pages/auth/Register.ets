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
  @State debugMode: boolean = true; // 调试模式

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
    console.info('Register: 开始注册流程');
    console.info(`Register: 用户名=${this.username}, 手机号=${this.phone}`);
    
    // 调试模式：跳过网络请求直接跳转
    if (this.debugMode) {
      console.info('Register: 调试模式，跳过网络请求');
      promptAction.showToast({
        message: '调试模式：直接跳转',
        duration: 2000
      });
      
      setTimeout(() => {
        router.pushUrl({
          url: 'pages/auth/Login'
        }).then(() => {
          console.info('Register: 调试模式跳转成功');
        }).catch((err: Error) => {
          console.error('Register: 调试模式跳转失败', err.message);
        });
      }, 1000);
      return;
    }
    
    // 验证输入
    this.usernameError = this.validateUsername(this.username);
    this.phoneError = this.validatePhone(this.phone);
    this.passwordError = this.validatePassword(this.password);

    if (this.usernameError || this.phoneError || this.passwordError) {
      console.warn('Register: 表单验证失败');
      return;
    }

    this.isLoading = true;
    console.info('Register: 开始发起注册请求');

    try {
      const response = await register(this.phone, this.password, this.username);
      console.info('Register: 收到响应', JSON.stringify(response));
      
      if (response.code === 200) {
        // 保存token
        await TokenManager.setToken(response.data.token);
        console.info('Register: Token已保存，准备跳转');
        
        promptAction.showToast({
          message: '注册成功，正在重定向..',
          duration: 2000
        });

        // 延迟跳转到登录页
        setTimeout(() => {
          console.info('Register: 开始跳转到登录页');
          router.pushUrl({
            url: 'pages/auth/Login'
          }).then(() => {
            console.info('Register: 成功跳转到登录页');
          }).catch((err: Error) => {
            console.error('Register: 跳转失败', err.message);
          });
        }, 1000);
      } else {
        console.warn('Register: 注册失败', response.message);
        promptAction.showToast({
          message: response.message || '注册失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Register: 注册错误', JSON.stringify(error));
      promptAction.showToast({
        message: '网络错误，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
      console.info('Register: 注册流程结束');
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
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E7D32') // Dark Green
        .margin({ top: 80, bottom: 40 })
        .letterSpacing(2)

      // 注册表单
      Column() {
        // 用户名输入框
        Column() {
          TextInput({ placeholder: '用户名', text: this.username })
            .height(50)
            .fontSize(16)
            .fontColor('#333333')
            .backgroundColor('#FAFAFA')
            .border({
              width: 1,
              color: this.usernameError ? '#FF4444' : '#E0E0E0',
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
              .margin({ top: 5, left: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 手机号输入框
        Column() {
          TextInput({ placeholder: '手机号', text: this.phone })
            .height(50)
            .fontSize(16)
            .fontColor('#333333')
            .backgroundColor('#FAFAFA')
            .border({
              width: 1,
              color: this.phoneError ? '#FF4444' : '#E0E0E0',
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
              .margin({ top: 5, left: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 密码输入框
        Column() {
          TextInput({ placeholder: '密码(字母+数字,至少6位)', text: this.password })
            .type(InputType.Password)
            .height(50)
            .fontSize(14)
            .fontColor('#333333')
            .backgroundColor('#FAFAFA')
            .border({
              width: 1,
              color: this.passwordError ? '#FF4444' : '#E0E0E0',
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
              .margin({ top: 5, left: 5 })
          }
        }
        .width('100%')
        .margin({ bottom: 40 })

        // 按钮组
        Row() {
          // 返回按钮
          Button('返回')
            .width('40%')
            .height(50)
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor('#FFFFFF')
            .border({ 
              width: 1,
              color: '#CCCCCC',
              radius: 25
            })
            .onClick(() => {
              this.goBack();
            })

          // 注册按钮
          Button(this.isLoading ? '注册中...' : '立即注册')
            .width('55%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor(this.isLoading ? '#A5D6A7' : '#4CAF50')
            .border({ radius: 25 })
            .shadow({ radius: 5, color: '#4CAF5040', offsetY: 5 })
            .enabled(!this.isLoading)
            .onClick(() => {
              console.info('Register: 注册按钮被点击');
              promptAction.showToast({
                message: '开始注册...',
                duration: 1000
              });
              this.handleRegister();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        
        // 调试模式开关
        Row() {
          Text('调试模式:')
            .fontSize(14)
            .fontColor('#666666')
          Toggle({ type: ToggleType.Switch, isOn: this.debugMode })
            .selectedColor('#4CAF50')
            .margin({ left: 10 })
            .onChange((isOn: boolean) => {
              this.debugMode = isOn;
              promptAction.showToast({
                message: `调试模式: ${isOn ? '开启' : '关闭'}`,
                duration: 2000
              });
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 20 })
      }
      .width('85%')
      .padding({ top: 40, bottom: 40, left: 25, right: 25 })
      .backgroundColor('#FFFFFF')
      .border({ radius: 16, width: 1, color: '#EEEEEE' })
      .shadow({
        radius: 20,
        color: '#0000000A',
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F9F9F9')
    .justifyContent(FlexAlign.Start)
    .padding({ top: 20 })
  }
}