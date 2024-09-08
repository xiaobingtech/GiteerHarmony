import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserModel } from '../../model/UserModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { UserItem } from '../search/UserItem'
import { promptAction } from '@kit.ArkUI'
import { efRcpClientApi } from '@yunkss/ef_rcp'

export class UserListParam {
  isMe: boolean = false
  type: string = ''
  login: string|null = ''
}

@Builder
export function UserListViewBuilder(name: string, param: Object) {
  UserListView()
}

@Component
export struct UserListView{

  @State param: UserListParam|null = null

  @State page: number = 1

  @State isRefreshing: boolean = true
  @State isFooterRefreshing:boolean = false

  @Prop @Watch('getUsers') q:string

  @State users: Array<UserModel> = []

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    NavDestination(){
      Column() {
        if (this.isRefreshing && this.users.length == 0) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          Refresh({refreshing:$$this.isRefreshing}){
            List(){
              ForEach(this.users, (item: UserModel) => {
                UserItem({ item: item })
                  .onClick(() => {
                    if (this.derivedStack != null) {
                      this.derivedStack.pushPath({name: 'UserView', param: item})
                    }
                  })
              }, (item: UserModel) => item.name)
            }
            .width('100%')
            .height('100%')
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
    .onReady((context) => {
      this.param = context.pathInfo.param as UserListParam
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.headerRefresh()
    })
    .title(this.param?.type == 'followers' ? '关注' : '粉丝')
  }

  headerRefresh(){
    this.page = 1
    this.getUsers()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.users.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getUsers()
  }

  async getUsers() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let prefix = ''
    if (this.param?.isMe) {
      prefix = `https://gitee.com/api/v5/user/${this.param?.type}`
    }else{
      prefix = `https://gitee.com/api/v5/users/${this.param?.login}/${this.param?.type}`
    }
    let url = `${prefix}?access_token=${tokenData.getSync('access_token', '')}&perpage=100&page=${this.page}`
    let response = await efRcpClientApi.get<Array<UserModel>>({
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
      this.users = result!
    }else{
      this.users.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}