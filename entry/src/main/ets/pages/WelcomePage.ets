import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI';

@Entry
@Component
struct WelcomePage {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('WelcomePageHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let access_token = data.getSync('access_token', '')
      if (access_token != null) {
        router.replaceUrl({
            url: 'pages/TabPage'
          })
      }else{
        router.replaceUrl({
          url: 'pages/Index'
        })
      }
    })
  }
}