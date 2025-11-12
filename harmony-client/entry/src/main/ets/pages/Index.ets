@Entry
@Component
struct Index {
  @State message: string = 'Mobile Internet HarmonyOS Client'
  @State backendStatus: string = 'Not connected'

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 40, bottom: 20 })

        Text('Welcome to Mobile Internet Application')
          .fontSize(16)
          .opacity(0.7)
          .margin({ bottom: 40 })

        Column() {
          Text('Backend Connection')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })

          Text(`Status: ${this.backendStatus}`)
            .fontSize(14)
            .opacity(0.8)
            .margin({ bottom: 20 })

          Button('Connect to Backend')
            .onClick(() => {
              this.connectToBackend()
            })
            .width('80%')
            .margin({ bottom: 10 })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .margin({ top: 20 })

        Text('Features')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 40, bottom: 20 })

        List({ space: 10 }) {
          ListItem() {
            this.FeatureCard('Web Frontend', 'Built with Vue.js')
          }
          ListItem() {
            this.FeatureCard('Backend API', 'Spring Boot REST API')
          }
          ListItem() {
            this.FeatureCard('HarmonyOS Client', 'Native HarmonyOS app')
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
    }
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder FeatureCard(title: string, description: string) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Text(description)
          .fontSize(14)
          .opacity(0.6)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(15)
    .backgroundColor('#F0F0F0')
    .borderRadius(8)
  }

  async connectToBackend() {
    // Placeholder for backend connection logic
    // In a real application, you would use http module to connect to the backend
    this.backendStatus = 'Attempting to connect...'
    
    // Simulate connection attempt
    setTimeout(() => {
      this.backendStatus = 'Connected (Demo mode)'
    }, 1000)
  }
}
