import { it } from '@ohos/hypium';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';
import { preferences } from '@kit.ArkData';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function RepoPageBuilder(name: string, param: Object) {
  RepoPage()
}

@Component
export struct RepoPage {
  @State item: StarResponse = new StarResponse()

  derivedStack: DerivedNavPathStack | null = null;

  @Builder NavigationMenus() {
    Row() {
      SymbolGlyph($r(this.item.starred ? 'sys.symbol.star' : 'sys.symbol.star_fill'))
        .fontSize(24)
    }
    .padding(15)
    .onClick(() => {
      const session = rcp.createSession()
      let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let url = `https://gitee.com/api/v5/user/starred/${this.item.full_name}?access_token=${tokenData.getSync('access_token', '')}`
      console.log('当前URL:',url)
      if (this.item.starred) {
        session.put(url).then((response) => {
          console.info(`Response succeeded: ${response}`);
          this.item.starred = false
        }).catch((err: BusinessError) => {
          console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
        })
      }else{
        session.delete(url).then((response) => {
          console.info(`Response succeeded: ${response}`);
          this.item.starred = true
        }).catch((err: BusinessError) => {
          console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
        })
      }
    })
  }

  build() {
    NavDestination(){
      Column(){
        Row({space: 15}){
          Image(this.item.owner.avatar_url)
            .width(50)
            .borderRadius(25)
          Column({space: 5}){
            Text(this.item.name)
            Text(this.item.description)
            Text(this.item.updated_at)
          }
          .alignItems(HorizontalAlign.Start)
          .width('calc(100% - 70vp)')
        }
        .alignItems(VerticalAlign.Top)
        .padding(15)
        Divider()
        Row(){
          Text('代码')
          Blank()
          SymbolGlyph($r('sys.symbol.chevron_right'))
        }
        .onClick(() => {
          if (this.derivedStack) {
            this.derivedStack.pushPath({name: 'RepoTreePage', param: this.item})
          }
        })
        .width('100%')
        .height(44)
        .padding(15)
        Divider()
        Row(){
          Text('README')
          Blank()
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
        }
        .onClick(() => {

        })
        .width('100%')
        .height(44)
        .padding(15)
        Divider()
      }
    }
    .onReady((context) => {
      this.item = context.pathInfo.param as StarResponse
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .title('仓库')
    .menus(this.NavigationMenus())
  }
}