import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct EditProfile {
  @State username: string = '用户名';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;

  goBack() {
    router.back();
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
      // 这里应该调用API保存用户信息
      // 暂时使用模拟保存
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      promptAction.showToast({
        message: '保存成功',
        duration: 2000
      });
      
      router.back();
    } catch (error) {
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
          Circle({ width: 80, height: 80 })
            .fill('#E0E0E0')
            .overlay(
              Text('头像')
                .fontSize(14)
                .fontColor('#999999')
            )
            .onClick(() => {
              promptAction.showToast({
                message: '头像上传功能开发中...',
                duration: 2000
              });
            })
          
          Text('点击更换头像')
            .fontSize(14)
            .fontColor('#007AFF')
            .margin({ top: 10 })
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
