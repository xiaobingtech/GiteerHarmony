import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { CommitModel } from '../../../model/CommitModel'
import { preferences } from '@kit.ArkData'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { CommitItem } from './CommitItem'

@Builder
export function CommitViewBuilder(name: string, param: Object) {
  CommitView()
}

@Component
struct CommitView{


  @State name: string = ''

  @State isRefreshing: boolean = false
  @State isFooterRefreshing:boolean = false

  @State page: number = 1

  @State commits: Array<CommitModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  build() {
    NavDestination(){
      Column(){
        if (this.commits.length > 0) {
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
        }else{
          LoadingProgress()
            .width(100)
            .height('100%')
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
    if (this.isFooterRefreshing) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getCommits()
  }

  getCommits() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/repos/GiteerApp/GiteerAndroid/commits?access_token=c3ddaabfcac3e76db1e3200da4021620&page=1&per_page=20
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/commits?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<CommitModel> = JSON.parse(jsonStr)
        if (this.page == 1) {
          this.commits = result
        }else{
          this.commits.push(...result)
        }
      }
      this.isRefreshing = false
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isRefreshing = false
    })
  }
}