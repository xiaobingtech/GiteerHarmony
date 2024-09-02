import { it } from '@ohos/hypium';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';

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
      this.item.starred = !this.item.starred
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