import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { CommitModel } from '../../../model/CommitModel'
import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { CommitItem } from './CommitItem'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'

@Builder
export function CommitViewBuilder(name: string, param: Object) {
  CommitView()
}

@Component
struct CommitView{


  @State name: string = ''

  @State isRefreshing: boolean = true
  @State isFooterRefreshing:boolean = false

  @State page: number = 1

  @State commits: Array<CommitModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  build() {
    NavDestination(){
      Column(){
        if (this.isRefreshing && this.commits.length == 0) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          Refresh({refreshing: $$this.isRefreshing}){
            List(){
              ForEach(this.commits, (item: CommitModel) => {
                CommitItem({ item: item})
                  .onClick(() => {
                    if (this.derivedStack != null) {
                      this.derivedStack.pushPath({name: 'WebView', param: item.html_url})
                    }
                  })
              }, (item: CommitModel) => item.sha)
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
    .title('所有提交')
    .onReady((context) =>{
      this.name = context.pathInfo.param as string
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.getCommits()
    })
  }

  headerRefresh(){
    this.page = 1
    this.getCommits()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.commits.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getCommits()
  }

  async getCommits() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/commits?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}`
    let response = await efRcpClientApi.get<Array<CommitModel>>({
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
      this.commits = result!
    }else{
      this.commits.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}