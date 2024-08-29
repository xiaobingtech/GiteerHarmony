import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { Constraints } from '../Constraints';
import { rcp } from '@kit.RemoteCommunicationKit';
import { LoginResponse } from '../model/LoginResponse';
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct WebPage {
  controller: webview.WebviewController = new webview.WebviewController()

  build() {
    Column(){
      Web({
        src: `https://gitee.com/oauth/authorize?client_id=${Constraints.client_id}&redirect_uri=${Constraints.redirect_uri}&response_type=code`,
        controller:this.controller
      })
        .onOverrideUrlLoading((request: WebResourceRequest) => {
          console.log('当前加载的URL:', request.getRequestUrl())
          if (request.getRequestUrl().startsWith(Constraints.redirect_uri)) {
            let code = request.getRequestUrl().split('code=').pop()
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
                let result: LoginResponse = JSON.parse(jsonStr)
                //存储数据
                let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
                data?.putSync('access_token', result.access_token)
                data?.putSync('refresh_token', result.refresh_token)
                data?.flush()
              }
              router.replaceUrl({
                url: 'pages/TabPage'
              })
            }).catch((err: BusinessError) => {
              console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
            })
            return false
          }
          return true
        })
        .width('100%')
        .height('100%')
    }
    .height('100%')
    .width('100%')
  }
}