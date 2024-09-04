import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { Constraints } from '../Constraints';
import { rcp } from '@kit.RemoteCommunicationKit';
import { LoginModel } from '../model/LoginModel';
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';
import { UserModel } from '../model/UserModel';
import { DerivedNavPathStack } from '../common/DerivedNavPathStack';

@Entry
@Component
export struct WebPage {
  @State url: string = ''
  @State title: string = ''
  controller: webview.WebviewController = new webview.WebviewController()

  progress: number = 0

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  build() {
    NavDestination(){
      Column(){
        if (this.title.length == 0) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }
        Web({
          src: this.url,
          controller:this.controller
        })
          .onProgressChange((data) =>{
            this.progress = data.newProgress
          })
          .onOverrideUrlLoading((request: WebResourceRequest) => {
            console.log('当前加载的URL:', request.getRequestUrl())
            if (request.getRequestUrl().startsWith(Constraints.redirect_uri)) {
              let code = request.getRequestUrl().split('code=').pop()
              this.handleCode(code)
              return true
            }
            return false
          })
          .width('100%')
          .height('100%')
          .onTitleReceive((data) => {
            this.title = data.title
          })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .onReady((context) => {
      this.url = context.pathInfo.param as string
    })
    .title(this.title)
  }

  handleCode(code: string|undefined) {
    const session = rcp.createSession()
    session.post("https://gitee.com/oauth/token", {
      'grant_type':'authorization_code',
      'code': code,
      'client_id': Constraints.client_id,
      'redirect_uri': Constraints.redirect_uri,
      'client_secret': Constraints.client_secret
    }).then((response) => {
      console.info(`Response succeeded: ${response}`);
      // {"access_token":"1f929233277fc8f9ccd8d39d29c0e946","token_type":"bearer","expires_in":86400,"refresh_token":"34433cfe6e7eea90cdf797b01789529291a4632d93c1038e34c5e36aa8b9d94e","scope":"user_info projects pull_requests issues notes keys hook groups gists enterprises emails","created_at":1719303807}
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: LoginModel = JSON.parse(jsonStr)
        //存储数据
        let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
        data?.putSync('access_token', result.access_token)
        data?.putSync('refresh_token', result.refresh_token)
        data?.flush()
        this.getUser(result.access_token)
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }

  getUser(access_token: string) {
    const session = rcp.createSession()
    session.get("https://gitee.com/api/v5/user?access_token="+access_token).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: UserModel = JSON.parse(jsonStr)
        //存储数据
        let data = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
        data?.putSync('login', result.login)
        data?.flush()
        router.replaceUrl({
          url: 'pages/TabPage'
        })
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}