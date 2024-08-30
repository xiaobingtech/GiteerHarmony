import { StarResponse } from '../../model/StarResponse'
import { StarItem } from './StarItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export struct StarView{

  @State repos: Array<StarResponse> = []
  @State prev_id: number = 0

  build() {
    Row(){
      Column(){
        Text('Star')
        if (this.repos.length > 0) {
          List(){
            ForEach(this.repos, (item: StarResponse) => {
              StarItem({ item: item })
            }, (item: StarResponse) => item.name)
          }
        }else{
          Text('暂无数据')
        }
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .backgroundColor(0xF1F3F5)
    .onAppear(() => {
      this.getStars()
    })
  }

  getStars() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/users/${userData.getSync('login', '')}/starred?access_token=${tokenData.getSync('access_token', '')}&limit=100&sort=created&direction=desc`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<StarResponse> = JSON.parse(jsonStr)
        this.repos = result
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}