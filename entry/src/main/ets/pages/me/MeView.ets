import { preferences } from '@kit.ArkData'
import { promptAction, router } from '@kit.ArkUI'
import { UserModel } from '../../model/UserModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { UserListParam } from './UserListView'
import { efRcpClientApi } from '@yunkss/ef_rcp'

@Component
export struct MeView{

  @State item: UserModel|null = null

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Navigation(){
      Column() {
        if (this.item?.login != '') {
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
                param.isMe = true
                param.type = 'repos'
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
                param.isMe = true
                param.type = 'subscriptions'
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
                param.isMe = true
                param.type = 'following'
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
                param.isMe = true
                param.type = 'followers'
                this.derivedStack.pushPath({name: 'UserListView', param: param})
              }
            })
            Divider()
              .vertical(true)
          }
          .width('100%')
          .height(50)
          Divider()
          Row(){
            Text('消息通知')
            Blank()
            SymbolGlyph($r('sys.symbol.chevron_right'))
          }
          .onClick(() => {
            if (this.derivedStack) {
              this.derivedStack.pushPath({name: 'MessageView'})
            }
          })
          .width('100%')
          .height(44)
          .padding(15)
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
            Text('设置')
            Blank()
            SymbolGlyph($r('sys.symbol.chevron_right'))
          }
          .onClick(() => {
            if (this.derivedStack) {
              this.derivedStack.pushPath({name: 'SettingView'})
            }
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
    .onAppear(() => {
      this.getUser()
    })
    .title('我的')
  }

  async getUser() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/user?access_token=${tokenData.getSync('access_token', '')}`
    let response = await efRcpClientApi.get<UserModel>({
      url: url
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data!
    let data = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    data?.putSync('login', result.login)
    data?.flush()
    this.item = result
  }
}