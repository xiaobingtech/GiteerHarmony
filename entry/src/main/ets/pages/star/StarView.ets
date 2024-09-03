import { StarResponse } from '../../model/StarResponse'
import { StarItem } from './StarItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'


@Component
export struct StarView{

  @State repos: Array<StarResponse> = []
  @State prev_id: number = 0

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Navigation(){
      Row(){
        Column(){
          if (this.repos.length > 0) {
            List(){
              ForEach(this.repos, (item: StarResponse) => {
                StarItem({ item: item })
                  .onClick(() => {
                    if (this.derivedStack != null) {
                      if (this.derivedStack.size() == 0) {
                        this.derivedStack.pushPath({name: 'RepoPage', param: item.full_name})
                      }else{
                        this.derivedStack.replacePath({name: 'RepoPage', param: item.full_name})
                      }
                    }
                  })
              }, (item: StarResponse) => item.name)
            }
            .scrollBar(BarState.Off)
            .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
            .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
            .width('100%')
          }else{
            LoadingProgress()
              .width('25%')
          }
        }
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .title('Star')
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