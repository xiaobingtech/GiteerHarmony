import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { UserModel } from '../../model/UserModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export struct MeView{

  @State item: UserModel|null = null

  build() {
    Navigation(){
          // Text('退出登录')
          //   .onClick(() => {
          //     let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
          //     data.putSync('access_token', '')
          //     data.putSync('refresh_token', '')
          //     data.flush()
          //     router.replaceUrl({
          //       url: "pages/Index"
          //     })
          //   })
      Row({space: 15}){
        Image(this.item?.avatar_url)
          .width(50)
          .borderRadius(25)
        Column({space: 5}){
          Text(this.item?.name)
            .maxLines(2)
          Text(this.item?.bio)
            .maxLines(2)
          Text(this.item?.created_at)
        }
        .alignItems(HorizontalAlign.Start)
        .width('calc(100% - 70vp)')
      }
      .alignItems(VerticalAlign.Top)
      .padding(15)
    }
    .onAppear(() => {
      this.getUser()
    })
    .title('我的')
  }

  getUser() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    const session = rcp.createSession()
    session.get("https://gitee.com/api/v5/user?access_token="+tokenData.getSync('access_token', '')).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: UserModel = JSON.parse(jsonStr)
        //存储数据
        let data = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
        data?.putSync('login', result.login)
        data?.flush()
        this.item = result
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}