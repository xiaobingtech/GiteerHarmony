import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserModel } from '../../model/UserModel'
import { UserItem } from './UserItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'
import { RepoModel } from '../../model/RepoModel'
import { EmptyListView } from '../../common/EmptyListView'

@Component
export struct SearchRepoListView{

  @State page: number = 1

  @State isRefreshing: boolean = false
  @State isFooterRefreshing:boolean = false

  @Prop @Watch('headerRefresh') q:string

  @State repos: Array<RepoModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column() {
      if (!this.isRefreshing && this.repos.length == 0 && this.q.length){
        EmptyListView({retryClick: () => this.headerRefresh()})
      }else{
        Refresh({refreshing:$$this.isRefreshing}){
          List(){
            ForEach(this.repos, (item: UserModel) => {
              UserItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    this.derivedStack.pushPath({name: 'UserView', param: item.login})
                  }
                })
            }, (item: UserModel) => item.name)
          }
          .scrollBar(BarState.Off)
          .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
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

  headerRefresh():void{
    this.page = 1
    this.getRepos()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.repos.length < 20) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getRepos()
  }

  async getRepos() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `api/v5/search/repositories?access_token=${tokenData.getSync('access_token', '')}&perpage=100&page=${this.page}&order=desc&q=${this.q}`
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