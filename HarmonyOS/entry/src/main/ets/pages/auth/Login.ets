import * as AuthApi from '../../model/api/AuthApi.js';
import TokenManager from '../../utils/TokenManager.js';
import Router from '../../router/RouterManager.js';

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State error: string = '';

  build() {
    Column() {
      Text('饮食记录')
        .fontSize('32px')
        .fontWeight(FontWeight.Bold)
        .height('120px')

      Column() {
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
          Text('没有账号?')
            .fontSize('14px')

          (Button('立即注册') as any)
            .onClick(() => { Router.push('Register'); })
        }

        if (this.error !== '') {
          Text(this.error).fontSize('14px')
        }

        (Button('登录') as any)
          .width('260px')
          .height('44px')
          .onClick(() => { this.onLogin(); })
      }
      .padding('20px')
      .width('320px')
    }
    .height('100%')
  }

  async onLogin() {
    this.error = '';
    if (!this.phone || !this.password) {
      this.error = '手机号和密码不能为空';
      return;
    }
    this.loading = true;
    try {
      const res = await AuthApi.login(this.phone, this.password);
      if (res && res.code === 200 && res.data && res.data.token) {
        TokenManager.setToken(res.data.token);
        Router.push('Index');
      } else {
        this.error = res && res.message ? res.message : '登录失败';
      }
    } catch (err) {
      this.error = '网络或服务错误';
      console.error(err);
    } finally {
      this.loading = false;
    }
  }
}
