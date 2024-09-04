import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { EventModel } from '../../model/EventModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { EventItem } from './EventItem'

@Component
export struct EventView{

  @State events: Array<EventModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Navigation(){
      Column(){
        if (this.events.length > 0) {
          List(){
            ForEach(this.events, (item: EventModel) => {
              EventItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    if (this.derivedStack.size() == 0) {

                    }else{

                    }
                  }
                })
            }, (item: EventModel) => item.id.toString())
          }
          .scrollBar(BarState.Off)
          .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
          .width('100%')
          .height('100%')
        }else{
          LoadingProgress()
            .width('25%')
            .height('100%')
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('动态')
    .onAppear(() => {
      this.getEvents()
    })
  }

  getEvents() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/users/${userData.getSync('login', '')}/received_events?access_token=${tokenData.getSync('access_token', '')}&limit=100`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<EventModel> = JSON.parse(jsonStr)
        this.events = result
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}