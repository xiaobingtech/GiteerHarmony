import { rcp } from '@kit.RemoteCommunicationKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { RepoModel } from '../../model/RepoModel'
import { StarItem } from '../star/StarItem'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { UserListParam } from './UserListView'
import { User } from '../../model/EventModel'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'

@Builder
export function RepoListViewBuilder(name: string, param: Object) {
  RepoListView()
}

@Component
export struct RepoListView{

  @State param: UserListParam|null = null

  @State page: number = 1

  @State isRefreshing: boolean = true
  @State isFooterRefreshing:boolean = false

  @State repos: Array<RepoModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  build() {
    NavDestination(){
      Column(){
        if (this.isRefreshing && this.repos.length == 0) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          Refresh({refreshing: $$this.isRefreshing}){
            List(){
              ForEach(this.repos, (item: RepoModel) => {
                StarItem({ item: item })
                  .onClick(() => {
                    if (this.derivedStack != null) {
                      if (this.derivedStack.size() == 0) {
                        this.derivedStack.pushPath({name: 'RepoView', param: item.full_name})
                      }else{
                        this.derivedStack.replacePath({name: 'RepoView', param: item.full_name})
                      }
                    }
                  })
              }, (item: RepoModel) => item.name)
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
    .title('仓库')
    .onReady((context) => {
      this.param = context.pathInfo.param as UserListParam
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh(){
    this.page = 1
    this.getRepos()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.repos.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getRepos()
  }

  async getRepos() {
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `api/v5/users/${this.param?.isMe ? userData.getSync('login', '') : this.param?.login}/${this.param?.type}?access_token=${tokenData.getSync('access_token', '')}&perpage=100&direction=desc&page=${this.page}`
    let response = await efRcpClientApi.get<Array<RepoModel>>({
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
      this.repos = result!
    }else{
      this.repos.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false

  }
}