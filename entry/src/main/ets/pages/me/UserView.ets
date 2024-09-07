import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { UserModel } from '../../model/UserModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserListParam } from './UserListView'

@Builder
export function UserViewBuilder(name: string, param: Object) {
  UserView()
}

@Component
export struct UserView{

  @State item: UserModel|null = null
  @State login: string|null = null

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    NavDestination(){
      Column() {
        if (this.item) {
          Row({ space: 15 }) {
            Image(this.item?.avatar_url)
              .width(50)
              .borderRadius(25)
            Column({ space: 5 }) {
              Text(this.item?.name)
                .maxLines(2)
              Text(this.item?.bio)
                .maxLines(2)
              Text(this.item?.created_at)
            }
            .alignItems(HorizontalAlign.Start)
            .width('calc(100% - 70vp)')
          }
          .alignItems(VerticalAlign.Top)
          .padding(15)
          Divider()
          Row() {
            Column(){
              Text('仓库')
              Text(`${this.item?.public_repos}`)
            }
            .layoutWeight(1)
            .align(Alignment.Center)
            .onClick(() => {
              if (this.derivedStack) {
                let param = new UserListParam()
                param.isMe = false
                param.type = 'repos'
                param.login = this.login
                this.derivedStack.pushPath({name: 'RepoListView', param: param})
              }
            })
            Divider()
              .vertical(true)
            Column(){
              Text('Watched')
              Text(`${this.item?.watched}`)
            }
            .layoutWeight(1)
            .align(Alignment.Center)
            .onClick(() => {
              if (this.derivedStack) {
                let param = new UserListParam()
                param.isMe = false
                param.type = 'subscriptions'
                param.login = this.login
                this.derivedStack.pushPath({name: 'RepoListView', param: param})
              }
            })
            Divider()
              .vertical(true)
            Column(){
              Text('关注')
              Text(`${this.item?.following}`)
            }
            .layoutWeight(1)
            .align(Alignment.Center)
            .onClick(() => {
              if (this.derivedStack) {
                let param = new UserListParam()
                param.isMe = false
                param.type = 'following'
                param.login = this.login
                this.derivedStack.pushPath({name: 'UserListView', param: param})
              }
            })
            Divider()
              .vertical(true)
            Column(){
              Text('粉丝')
              Text(`${this.item?.followers}`)
            }
            .layoutWeight(1)
            .align(Alignment.Center)
            .onClick(() => {
              if (this.derivedStack) {
                let param = new UserListParam()
                param.isMe = false
                param.type = 'followers'
                param.login = this.login
                this.derivedStack.pushPath({name: 'UserListView', param: param})
              }
            })
            Divider()
              .vertical(true)
          }
          .width('100%')
          .height(50)
          Divider()
          if (this.item?.email != '') {
            Row(){
              Text(this.item?.email)
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
          }
          Row(){
            Text('私信')
            Blank()
            SymbolGlyph($r('sys.symbol.chevron_right'))
          }
          .onClick(() => {

          })
          .width('100%')
          .height(44)
          .padding(15)
          Divider()
        } else {
          LoadingProgress()
            .width(100)
            .height('100%')
        }
      }
    }
    .onReady((context) => {
      this.derivedStack = context.pathStack as DerivedNavPathStack
      this.login = context.pathInfo.param as string
    })
    .onAppear(() => {
      this.getUser()
    })
    .title('TA')
  }

  getUser() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    const session = rcp.createSession()
    let url = `https://gitee.com/api/v5/users/${this.login}?access_token=${tokenData.getSync('access_token', '')}`
    console.log('当前请求URL:', url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: UserModel = JSON.parse(jsonStr)
        this.item = result
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}