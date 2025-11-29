import router from '@ohos.router';
import { login } from '../../model/api/AuthApi';
import TokenManager from '../../utils/TokenManager';
import promptAction from '@ohos.promptAction';
import NetworkTest from '../../utils/NetworkTest';
import { ApiConfig } from '../../config/ApiConfig';

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State phoneError: string = '';
  @State passwordError: string = '';
  @State debugMode: boolean = true; // 调试模式

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

  // 切换服务器地址
  switchServerAddress() {
    const newAddress = ApiConfig.switchToNextAddress();
    promptAction.showToast({
      message: `切换服务器地址: ${newAddress}`,
      duration: 3000
    });
  }

  // 测试网络连接
  async testNetwork() {
    console.info('Login: 开始测试网络连接');
    
    // 显示当前使用的API地址
    promptAction.showToast({
      message: '正在测试网络连接...',
      duration: 1000
    });
    
    try {
      // 先测试基本网络连接
      const isConnected = await NetworkTest.testConnection();
      if (isConnected) {
        promptAction.showToast({
          message: '网络连接正常',
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '网络连接失败，请检查后端服务',
          duration: 3000
        });
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error('Login: 网络测试错误', errorMessage);
      promptAction.showToast({
        message: `网络测试失败: ${errorMessage}`,
        duration: 3000
      });
    }
  }

  // 登录处理
  async handleLogin() {
    console.info('Login: 开始登录流程');
    console.info(`Login: 手机号=${this.phone}`);
    
    // 调试模式：跳过网络请求直接跳转
    if (this.debugMode) {
      console.info('Login: 调试模式，跳过网络请求');
      promptAction.showToast({
        message: '调试模式：直接跳转',
        duration: 2000
      });
      
      setTimeout(() => {
        router.pushUrl({
          url: 'pages/Index'
        }).then(() => {
          console.info('Login: 调试模式跳转成功');
        }).catch((err: Error) => {
          console.error('Login: 调试模式跳转失败', err.message);
        });
      }, 1000);
      return;
    }
    
    // 验证输入
    this.phoneError = this.validatePhone(this.phone);
    this.passwordError = this.validatePassword(this.password);

    if (this.phoneError || this.passwordError) {
      console.warn('Login: 表单验证失败');
      return;
    }

    this.isLoading = true;
    console.info('Login: 开始发起登录请求');

    try {
      const response = await login(this.phone, this.password);
      console.info('Login: 收到响应', JSON.stringify(response));
      
      if (response.code === 200) {
        // 保存token
        await TokenManager.setToken(response.data.token);
        console.info('Login: Token已保存，准备跳转');
        
        promptAction.showToast({
          message: '登录成功',
          duration: 2000
        });

        // 跳转到主页
        console.info('Login: 开始跳转到主页');
        router.pushUrl({
          url: 'pages/Index'
        }).then(() => {
          console.info('Login: 成功跳转到主页');
        }).catch((err: Error) => {
          console.error('Login: 跳转失败', err.message);
        });
      } else {
        console.warn('Login: 登录失败', response.message);
        promptAction.showToast({
          message: response.message || '登录失败',
          duration: 2000
        });
      }
    } catch (error) {
      console.error('Login: 登录错误', JSON.stringify(error));
      promptAction.showToast({
        message: '网络错误，请重试',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
      console.info('Login: 登录流程结束');
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
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E7D32') // Dark Green
        .margin({ top: 80, bottom: 40 })
        .letterSpacing(2)

      // 登录表单
      Column() {
        // 手机号输入框
        Column() {
          TextInput({ placeholder: '请输入手机号', text: this.phone })
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
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(InputType.Password)
            .height(50)
            .fontSize(16)
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
        .margin({ bottom: 20 })

        // 注册引导
        Row() {
          Text('没有账号？')
            .fontSize(14)
            .fontColor('#666666')
          
          Button('立即注册')
            .type(ButtonType.Normal)
            .fontSize(14)
            .fontColor('#4CAF50')
            .backgroundColor('transparent')
            .border({ width: 1, color: '#4CAF50', radius: 4 })
            .height(30)
            .width(160)
            .margin({ left: 10 })
            .onClick(() => {
              this.goToRegister();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: 40 })

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor(this.isLoading ? '#A5D6A7' : '#4CAF50') // Green theme
          .border({ radius: 25 })
          .shadow({ radius: 5, color: '#4CAF5040', offsetY: 5 })
          .enabled(!this.isLoading)
          .onClick(() => {
            console.info('Login: 登录按钮被点击');
            promptAction.showToast({
              message: '开始登录...',
              duration: 1000
            });
            this.handleLogin();
          })
        
        // 测试网络连接按钮
        Button('测试网络连接')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .border({ width: 1, color: '#E0E0E0', radius: 20 })
          .margin({ top: 20 })
          .onClick(() => {
            console.info('Login: 测试网络按钮被点击');
            this.testNetwork();
          })
          
        // 切换服务器地址按钮
        Button('切换服务器地址')
          .width('100%')
          .height(40)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F0F8FF')
          .border({ width: 1, color: '#87CEEB', radius: 20 })
          .margin({ top: 10 })
          .onClick(() => {
            this.switchServerAddress();
          })
          
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
        .margin({ top: 10 })
          
        // 显示API地址信息
        Text(`API地址: ${ApiConfig.getCurrentBaseUrl()}`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 10 })
          .textAlign(TextAlign.Center)
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