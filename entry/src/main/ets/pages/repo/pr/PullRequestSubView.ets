import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { PullRequestItem } from './PullRequestItem'
import { PullRequestModel } from '../../../model/PullRequestModel'

@Component
export struct PullRequestSubView {
  @Prop name: string = ''
  @Prop state: string = 'open'
  @State page: number = 1
  @State isRefreshing: boolean = false
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
      if (this.pulls.length > 0) {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List() {
            ForEach(this.pulls, (item: PullRequestModel) => {
              PullRequestItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    // this.derivedStack.pushPath({ name: 'RepoPage', param: item.path_with_namespace })
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
      } else {
        LoadingProgress()
          .width(100)
          .height('100%')
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
    this.getIssues()
  }

  footerRefresh() {
    if (this.isFooterRefreshing) {
      return
    }
    this.isFooterRefreshing = true
    this.page++
    this.getIssues()
  }

  getIssues() {
    const session = rcp.createSession()
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    session.get(`https://gitee.com/api/v5/repos/${this.name}/issues?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}&state=${this.state}`).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<PullRequestModel> = JSON.parse(jsonStr)
        if (this.page == 1) {
          this.pulls = result
        } else {
          this.pulls.push(...result)
        }
      }
      this.isRefreshing = false
      this.isFooterRefreshing = false
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isRefreshing = false
      this.isFooterRefreshing = false
    })
  }
}