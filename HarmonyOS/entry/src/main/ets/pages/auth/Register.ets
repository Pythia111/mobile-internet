import * as AuthApi from '../../model/api/AuthApi.js';
import Router from '../../router/RouterManager.js';

@Component
struct Register {
  @State username: string = '';
  @State phone: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State error: string = '';
  @State success: string = '';

  build() {
    Column() {
      Text('饮食记录')
        .fontSize('32px')
        .fontWeight(FontWeight.Bold)
        .height('120px')

      Column() {
        (TextInput() as any)
          .text(this.username)
          .onChange((e: any) => { this.username = e.value })
          .width('260px')
          .height('40px')

        (TextInput() as any)
          .text(this.phone)
          .onChange((e: any) => { this.phone = e.value })
          .width('260px')
          .height('40px')

        (TextInput() as any)
          .text(this.password)
          .onChange((e: any) => { this.password = e.value })
          .width('260px')
          .height('40px')

        Row() {
          (Button('返回') as any)
            .onClick(() => { Router.push('Login'); })

          (Button('立即注册') as any)
            .width('140px')
            .height('44px')
            .onClick(() => { this.onRegister(); })
        }

        if (this.error !== '') {
          Text(this.error).fontSize('14px')
        }
        if (this.success !== '') {
          Text(this.success).fontSize('14px')
        }
      }
      .padding('20px')
      .width('320px')
    }
    .height('100%')
  }

  validatePassword(pw: string) {
    if (!pw || pw.length < 6) return false;
    const hasLetter = /[A-Za-z]/.test(pw);
    const hasNumber = /[0-9]/.test(pw);
    return hasLetter && hasNumber;
  }

  async onRegister() {
    this.error = '';
    this.success = '';
    if (!this.username || !this.phone || !this.password) {
      this.error = '请填写全部字段';
      return;
    }
    if (!this.validatePassword(this.password)) {
      this.error = '密码需至少6位并包含字母和数字';
      return;
    }
    this.loading = true;
    try {
      const res = await AuthApi.register(this.phone, this.password, this.username);
      if (res && res.code === 200) {
        this.success = '注册成功，请登录';
        Router.push('Login');
      } else {
        this.error = res && res.message ? res.message : '注册失败';
      }
    } catch (err) {
      this.error = '网络或服务错误';
      console.error(err);
    } finally {
      this.loading = false;
    }
  }
}
