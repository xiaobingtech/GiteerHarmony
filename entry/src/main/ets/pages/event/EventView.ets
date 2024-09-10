import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { EventModel } from '../../model/EventModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { EventItem } from './EventItem'
import { it } from '@ohos/hypium'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'

@Component
export struct EventView{

  @State isRefreshing: boolean = true
  @State isFooterRefreshing: boolean = false

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
    let url = `${item.repo.full_name}/commit/${item.payload.commits[0].sha}`
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'WebView', param: url})
      }else{
        this.derivedStack.replacePath({name: 'WebView', param: url})
      }
    }
  }

  onClickPull(item: EventModel): void {
    // https://gitee.com/harmonyos_codelabs/car-kit-codelab-arkts/pull/169ccb181c0d8a67dc69f774faf13a22fefd8555
    let url = item.payload.html_url
    if (url == null) {
      url = item.payload.pull_request.html_url
    }
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'WebView', param: url})
      }else{
        this.derivedStack.replacePath({name: 'WebView', param: url})
      }
    }
  }

  onClickIssue(item: EventModel): void {
    // https://gitee.com/harmonyos_codelabs/car-kit-codelab-arkts/commit/169ccb181c0d8a67dc69f774faf13a22fefd8555
    let number = item.payload.number
    if (number == null) {
      number = item.payload.issue.number
    }
    let url = `${item.repo.full_name}/issues/${number}`
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'WebView', param: url})
      }else{
        this.derivedStack.replacePath({name: 'WebView', param: url})
      }
    }
  }

  onClickAvatar(item: EventModel): void {
    // https://gitee.com/harmonyos_codelabs/car-kit-codelab-arkts/commit/169ccb181c0d8a67dc69f774faf13a22fefd8555
    let login = item.actor.login
    if (this.derivedStack != null) {
      if (this.derivedStack.size() == 0) {
        this.derivedStack.pushPath({name: 'UserView', param: login})
      }else{
        this.derivedStack.replacePath({name: 'UserView', param: login})
      }
    }
  }

  build() {
    Navigation(){
      Column(){
        if (this.isRefreshing && this.events.length == 0) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          Refresh({refreshing: $$this.isRefreshing}){
            List(){
              ForEach(this.events, (item: EventModel) => {
                EventItem({ item: item, repoClick: () => this.onClickRepo(item), commitClick: () => this.onClickCommit(item), pullClick: () => this.onClickPull(item), issueClick: () => this.onClickIssue(item), avatarClick: () => this.onClickAvatar(item)})
              }, (item: EventModel) => item.id.toString())
            }
            .scrollBar(BarState.Off)
            .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
            .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
            .width('100%')
            .height('100%')
            .onReachEnd(() =>{
              this.footerRefresh()
            })
          }
          .onRefreshing(() => {
            this.headerRefresh()
          })
          .refreshOffset(64)
          .pullToRefresh(true)
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

  headerRefresh(){
    this.prev_id = 0
    this.getEvents()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.events.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.getEvents()
  }

  async getEvents() {
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `api/v5/users/${userData.getSync('login', '')}/received_events?access_token=${tokenData.getSync('access_token', '')}&limit=100`
    if (this.prev_id != 0) {
      url = url +`&prev_id=${this.prev_id}`
    }
    let response = await efRcpClientApi.get<Array<EventModel>>({
      url: url
    })
    if (response.error) {
      this.isRefreshing = false
      this.isFooterRefreshing = false
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data
    if (this.prev_id == 0) {
      this.events = result!
    }else{
      this.events.push(...result!)
    }
    this.prev_id = result![result!.length - 1].id
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}