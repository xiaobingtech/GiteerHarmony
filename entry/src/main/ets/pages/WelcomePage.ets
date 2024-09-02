import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { Constraints } from '../Constraints';
import { LoginResponse } from '../model/LoginResponse';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct WelcomePage {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text('')
    }
    .height('100%')
    .width('100%')
    .onAppear(() => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let access_token = data.getSync('access_token', '')
      if (access_token != '') {
        //刷新Token
        let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
        let refresh_token = data?.getSync('refresh_token', '')

        //刷新Token
        //https://gitee.com/oauth/token?grant_type=refresh_token&refresh_token={refresh_token}
        const session = rcp.createSession()
        session.post("https://gitee.com/oauth/token", {
          'grant_type':'refresh_token',
          'refresh_token': refresh_token,
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
            if (result.message == null) {
              router.replaceUrl({
                url: 'pages/TabPage'
              })
            }else{

            }
          }
        }).catch((err: BusinessError) => {
          console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
        })

      }else{
        router.replaceUrl({
          url: 'pages/Index'
        })
      }
    })
  }
}