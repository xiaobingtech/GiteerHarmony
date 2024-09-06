import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { EventModel } from '../../model/EventModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { EventItem } from './EventItem'

@Component
export struct EventView{

  @State isRefreshing: boolean = false

  @State prev_id: number = 0

  @State events: Array<EventModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  onClickRepo(item: EventModel): void {
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'RepoView', param: item.repo.full_name})
      }else{
        this.derivedStack.replacePath({name: 'RepoView', param: item.repo.full_name})
      }
    }
  }

  onClickCommit(item: EventModel): void {
    // https://gitee.com/harmonyos_codelabs/car-kit-codelab-arkts/commit/169ccb181c0d8a67dc69f774faf13a22fefd8555
    let url = `https://gitee.com/${item.repo.full_name}/commit/${item.payload.commits[0].sha}`
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'WebView', param: url})
      }else{
        this.derivedStack.replacePath({name: 'WebView', param: url})
      }
    }
  }

  build() {
    Navigation(){
      Column(){
        if (this.events.length > 0) {
          Refresh({refreshing: $$this.isRefreshing}){
            List(){
              ForEach(this.events, (item: EventModel) => {
                EventItem({ item: item, repoClick: () => this.onClickRepo(item), commitClick: () => this.onClickCommit(item)})
              }, (item: EventModel) => item.id.toString())
            }
            .scrollBar(BarState.Off)
            .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
            .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
            .width('100%')
            .height('100%')
            .onReachEnd(() =>{
              this.getEvents()
            })
          }
          .onRefreshing(() => {
            this.getEvents()
          })
          .refreshOffset(64)
          .pullToRefresh(true)
        }else{
          LoadingProgress()
            .width(100)
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
    if (this.prev_id != 0) {
      url = url +`&prev_id=${this.prev_id}`
    }
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<EventModel> = JSON.parse(jsonStr)
        if (this.prev_id == 0) {
          this.events = result
        }else{
          this.events.push(...result)
        }
        this.prev_id = result[result.length - 1].id
      }
      this.isRefreshing = false
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isRefreshing = false
    })
  }
}