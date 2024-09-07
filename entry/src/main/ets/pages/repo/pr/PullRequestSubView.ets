import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { PullRequestItem } from './PullRequestItem'
import { PullRequestModel } from '../../../model/PullRequestModel'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'

@Component
export struct PullRequestSubView {
  @Prop name: string = ''
  @Prop state: string = ''
  @State page: number = 1
  @State isRefreshing: boolean = true
  @State isFooterRefreshing: boolean = false
  @Prop type: string = ''
  @State pulls: Array<PullRequestModel> = []
  @State prev_id: number = 0
  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column() {
      if (this.isRefreshing && this.pulls.length == 0) {
        LoadingProgress()
          .width(100)
          .height('100%')
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List() {
            ForEach(this.pulls, (item: PullRequestModel) => {
              PullRequestItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    this.derivedStack.pushPath({name: 'WebView', param: item.html_url})
                  }
                })
            }, (item: PullRequestModel) => `${item.id}`)
          }
          .scrollBar(BarState.Off)
          .divider({
            strokeWidth: 1,
            color: 0xFAFAFA,
            startMargin: 0,
            endMargin: 0
          }) // 每行之间的分界线
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
          .width('100%')
          .height('100%')
          .onReachEnd(() => {
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
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh() {
    this.page = 1
    this.getPulls()
  }

  footerRefresh() {
    if (this.isFooterRefreshing || this.pulls.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page++
    this.getPulls()
  }

  async getPulls() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/pulls?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}&state=${this.state}`
    let response = await efRcpClientApi.get<Array<PullRequestModel>>({
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
    if (this.page == 1) {
      this.pulls = result!
    }else{
      this.pulls.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}