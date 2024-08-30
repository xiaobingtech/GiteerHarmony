import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { EventView } from './event/EventView'
import { SearchView } from './search/SearchView'
import { StarView } from './star/StarView'
import { TrendView } from './trend/TrendView'

@Entry
@Component
struct TabPage {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = '';

  @State selectIndex : number = 0

  @Builder
  tabBarBuilder(index: number, title: string, img: ResourceStr, sel_img: ResourceStr) {
    if (this.currentBreakpoint !== 'md' ) {
      Column(){
        Image(index == this.selectIndex ? sel_img : img)
          .width(30)
        Text(title).fontColor(index == this.selectIndex ? Color.Red : Color.Black)
      }
    }else{
      Row(){
        Image(index == this.selectIndex ? sel_img : img)
          .width(30)
        Text(title).fontColor(index == this.selectIndex ? Color.Red : Color.Black)
      }
    }

  }

  build() {
    Tabs({ barPosition: this.currentBreakpoint === "lg" ? BarPosition.Start : BarPosition.End }) {
      TabContent() {
        NavDestination() {
          Navigation(){
            EventView()
          }
          .title('动态')
        }
      }
      .tabBar(this.tabBarBuilder(0, '动态', $r('app.media.event'), $r('app.media.event')))

      TabContent() {
        NavDestination() {
          Navigation(){
            StarView()
          }
          .title('Star')
        }
      }
      .tabBar(this.tabBarBuilder(1, 'Star', $r('app.media.star'), $r('app.media.star')))

      TabContent() {
        NavDestination() {
          Navigation(){
            SearchView()
          }
          .title('搜索')
        }
      }
      .tabBar(this.tabBarBuilder(2, '搜索', $r('app.media.search'), $r('app.media.search')))

      TabContent() {
        NavDestination() {
          Navigation(){
            TrendView()
          }
          .title('趋势')
        }
      }
      .tabBar(this.tabBarBuilder(3, '趋势', $r('app.media.star'), $r('app.media.star')))

      TabContent() {
        NavDestination() {
          Navigation(){
            Text('退出登录')
              .onClick(() => {
                let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
                data.putSync('access_token', '')
                data.putSync('refresh_token', '')
                data.flush()
                router.replaceUrl({
                  url: "pages/Index"
                })
              })
          }
          .title('我的')
        }
      }
      .tabBar(this.tabBarBuilder(4, '我', $r('app.media.me'), $r('app.media.me')))
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
    .onAppear(() => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let val = data?.getSync('access_token', '')
      //刷新Token
    })
  }
}