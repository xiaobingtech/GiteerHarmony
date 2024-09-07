import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { IssueModel } from '../../../model/IssueModel'
import { IssueItem } from './IssueItem'
import { promptAction } from '@kit.ArkUI'
import { efRcpClientApi } from '@yunkss/ef_rcp'

@Component
export struct IssueSubView {
  @Prop name: string = ''
  /// Issue的状态: open（开启的）, progressing(进行中), closed（关闭的）, rejected（拒绝的）。
  @Prop state: string = ''
  @State page: number = 1
  @State isRefreshing: boolean = true
  @State isFooterRefreshing: boolean = false
  @Prop type: string = ''
  @State issues: Array<IssueModel> = []
  @State prev_id: number = 0
  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column() {
      if (this.isRefreshing && this.issues.length == 0) {
        LoadingProgress()
          .width(100)
          .height('100%')
      } else {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List() {
            ForEach(this.issues, (item: IssueModel) => {
              IssueItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    this.derivedStack.pushPath({name: 'WebView', param: item.html_url})
                  }
                })
            }, (item: IssueModel) => `${item.id}`)
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
    this.getIssues()
  }

  footerRefresh() {
    if (this.isFooterRefreshing || this.issues.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page++
    this.getIssues()
  }

  async getIssues() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/issues?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}&state=${this.state}`
    let response = await efRcpClientApi.get<Array<IssueModel>>({
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
      this.issues = result!
    }else{
      this.issues.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}