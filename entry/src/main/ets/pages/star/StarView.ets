import { StarItem } from './StarItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { RepoModel } from '../../model/RepoModel'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'


@Component
export struct StarView{

  @State page: number = 1

  @State isRefreshing: boolean = true
  @State isFooterRefreshing:boolean = false

  @State repos: Array<RepoModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Navigation(){
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
    .title('Star')
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh(){
    this.page = 1
    this.getStars()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.repos.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getStars()
  }

  async getStars() {
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `api/v5/users/${userData.getSync('login', '')}/starred?access_token=${tokenData.getSync('access_token', '')}&perpage=100&sort=created&direction=desc&page=${this.page}`
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