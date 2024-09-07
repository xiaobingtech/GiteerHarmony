import { webview } from '@kit.ArkWeb';
import { promptAction, router } from '@kit.ArkUI';
import { Constraints } from '../Constraints';
import { rcp } from '@kit.RemoteCommunicationKit';
import { LoginModel } from '../model/LoginModel';
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';
import { UserModel } from '../model/UserModel';
import { DerivedNavPathStack } from '../common/DerivedNavPathStack';
import { efRcpClientApi } from '@yunkss/ef_rcp';

@Builder
export function WebViewBuilder(name: string, param: Object) {
  WebView()
}

@Entry
@Component
export struct WebView {
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
            console.log('当前加载URL:', request.getRequestUrl())
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

  async handleCode(code: string|undefined) {
    let response = await efRcpClientApi.post<LoginModel>({
      url: 'oauth/token',
      query: {
        'grant_type':'authorization_code',
        'code': code,
        'client_id': Constraints.client_id,
        'redirect_uri': Constraints.redirect_uri,
        'client_secret': Constraints.client_secret
      }
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data
    //存储数据
    let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    data?.putSync('access_token', result?.access_token)
    data?.putSync('refresh_token', result?.refresh_token)
    data?.flush()
    this.getUser(result!.access_token)
    return
  }

  async getUser(access_token: string) {
    let response = await efRcpClientApi.get<UserModel>({
      url: `api/v5/user?access_token=${access_token}`
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data
    //存储数据
    let data = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    data?.putSync('login', result?.login)
    data?.flush()
    router.replaceUrl({
      url: 'pages/TabPage'
    })
  }
}