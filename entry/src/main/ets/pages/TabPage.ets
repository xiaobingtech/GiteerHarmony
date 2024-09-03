import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../common/DerivedNavPathStack'
import { EventView } from './event/EventView'
import { MeView } from './me/MeView'
import { SearchView } from './search/SearchView'
import { StarView } from './star/StarView'
import { TrendView } from './trend/TrendView'

@Entry
@Component
struct TabPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = '';

  @State selectIndex : number = 0

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  aboutToAppear(): void {
    AppStorage.setOrCreate('derivedStack', this.derivedStack)
  }

  @Builder
  tabBarBuilder(index: number, title: string, img: string, sel_img: string) {
    if (this.currentBreakpoint !== 'md' ) {
      Column({space: 5}){
        SymbolGlyph(index == this.selectIndex ? $r(sel_img) : $r(img))
          .fontSize(30)
          .fontColor(index == this.selectIndex ? [Color.Blue] : [Color.Gray])
        Text(title).fontColor(index == this.selectIndex ? Color.Blue : Color.Black)
      }
    }else{
      Row({space: 5}){
        SymbolGlyph(index == this.selectIndex ? $r(sel_img) : $r(img))
          .fontSize(30)
          .fontColor(index == this.selectIndex ? [Color.Blue] : [Color.Gray])
        Text(title).fontColor(index == this.selectIndex ? Color.Blue : Color.Black)
      }
    }
  }

  build() {
    Navigation(this.derivedStack){
      Tabs({ barPosition: this.currentBreakpoint === "lg" ? BarPosition.Start : BarPosition.End }) {
        TabContent() {
          EventView()
        }
        .tabBar(this.tabBarBuilder(0, '动态', 'sys.symbol.square_grid_2x2', 'sys.symbol.square_fill_grid_2x2'))

        TabContent() {
          StarView()
        }
        .tabBar(this.tabBarBuilder(1, 'Star', 'sys.symbol.star', 'sys.symbol.star_fill'))

        TabContent() {
          SearchView()
        }
        .tabBar(this.tabBarBuilder(2, '搜索', 'sys.symbol.magnifyingglass', 'sys.symbol.magnifyingglass'))

        TabContent() {
          TrendView()
        }
        .tabBar(this.tabBarBuilder(3, '趋势', 'sys.symbol.discover_fill', 'sys.symbol.discover_fill'))

        TabContent() {
          MeView()
        }
        .tabBar(this.tabBarBuilder(4, '我', 'sys.symbol.person_crop_circle_fill_1', 'sys.symbol.person_crop_circle_fill_1'))
      }
      .onChange((index: number) => {
        this.selectIndex = index
      })
      .scrollable(false)
      .animationDuration(0)
      .width('100%')
      .barWidth(this.currentBreakpoint === "lg" ? 96 : '100%')
      .barHeight(this.currentBreakpoint === "lg" ? '60%' : 56)
      .vertical(this.currentBreakpoint === "lg")
    }
    .hideTitleBar(true)
  }
}