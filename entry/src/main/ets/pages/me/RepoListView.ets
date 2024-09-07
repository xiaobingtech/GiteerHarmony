import { rcp } from '@kit.RemoteCommunicationKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { RepoModel } from '../../model/RepoModel'
import { StarItem } from '../star/StarItem'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { UserListParam } from './UserListView'
import { User } from '../../model/EventModel'

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
        if (!this.isRefreshing) {
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
        }else{
          LoadingProgress()
            .width(100)
            .height('100%')
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

  getRepos() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/repos?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/users/${this.param?.isMe ? userData.getSync('login', '') : this.param?.login}/${this.param?.type}?access_token=${tokenData.getSync('access_token', '')}&perpage=100&direction=desc&page=${this.page}`
    console.log('当前请求URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoModel> = JSON.parse(jsonStr)
        if (this.page == 1) {
          this.repos = result
        }else{
          this.repos.push(...result)
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