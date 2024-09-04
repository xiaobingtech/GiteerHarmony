import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserModel } from '../../model/UserModel'
import { UserItem } from './UserItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'

@Component
export struct UserListView{

  @State page: number = 1

  @State isRefreshing: boolean = false
  @State isFooterRefreshing:boolean = false

  @Prop @Watch('getUsers') q:string

  @State users: Array<UserModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Row() {
      Column() {
        Refresh({refreshing:$$this.isRefreshing}){
          List(){
            ForEach(this.users, (item: UserModel) => {
              UserItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    if (this.derivedStack.size() == 0) {

                    }else{

                    }
                  }
                })
            }, (item: UserModel) => item.name)
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

  headerRefresh(){
    this.page = 1
    this.getUsers()
  }

  footerRefresh(){
    if (this.isFooterRefreshing) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getUsers()
  }

  getUsers() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/search/users?access_token=${tokenData.getSync('access_token', '')}&perpage=100&page=${this.page}&order=desc&q=${this.q}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<UserModel> = JSON.parse(jsonStr)
        if (this.page == 1) {
          this.users = result
        }else{
          this.users.push(...result)
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