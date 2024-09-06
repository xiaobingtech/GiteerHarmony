import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserModel } from '../../model/UserModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { preferences } from '@kit.ArkData'
import { UserItem } from '../search/UserItem'

export class UserListParam {
  isMe: boolean = false
  type: string = ''
  login: string|undefined = ''
}

@Builder
export function UserListViewBuilder(name: string, param: Object) {
  UserListView()
}

@Component
export struct UserListView{

  @State param: UserListParam|null = null

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
    NavDestination(){
      Row() {
        Column() {
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
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let prefix = ''
    if (this.param?.isMe) {
      prefix = `https://gitee.com/api/v5/user/${this.param?.type}`
    }else{
      prefix = `https://gitee.com/api/v5/users/${this.param?.login}/${this.param?.type}`
    }
    let url = `${prefix}?access_token=${tokenData.getSync('access_token', '')}&perpage=100&page=${this.page}`
    console.log('当前请求URL:',url)
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