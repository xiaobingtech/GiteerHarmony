import { StarItem } from './StarItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { RepoModel } from '../../model/RepoModel'


@Component
export struct StarView{

  @State page: number = 1

  @State isRefreshing: boolean = false
  @State isFooterRefreshing:boolean = false

  @State repos: Array<RepoModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Navigation(){
      Column(){
        if (this.repos.length > 0) {
          Refresh({refreshing: $$this.isRefreshing}){
            List(){
              ForEach(this.repos, (item: RepoModel) => {
                StarItem({ item: item })
                  .onClick(() => {
                    if (this.derivedStack != null) {
                      if (this.derivedStack.size() == 0) {
                        this.derivedStack.pushPath({name: 'RepoPage', param: item.full_name})
                      }else{
                        this.derivedStack.replacePath({name: 'RepoPage', param: item.full_name})
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
            this.getStars()
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
    if (this.isFooterRefreshing) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getStars()
  }

  getStars() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/users/${userData.getSync('login', '')}/starred?access_token=${tokenData.getSync('access_token', '')}&perpage=100&sort=created&direction=desc&page=${this.page}`
    console.log('当前URL:',url)
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