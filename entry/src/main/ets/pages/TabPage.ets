import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { EventView } from './event/EventView'
import { StarView } from './Star/StarView'

@Entry
@Component
struct TabPage {
  @State selectIndex : number = 0

  @Builder
  tabBarBuilder(index: number, title: string, img: ResourceStr, sel_img: ResourceStr) {
    Column(){
      Image(index == this.selectIndex ? sel_img : img)
        .width(30)
      Text(title).fontColor(index == this.selectIndex ? Color.Red : Color.Black)
    }
  }

  build() {
    Tabs({
      barPosition: BarPosition.End
    }) {
      TabContent() {
        NavDestination() {
          EventView()
        }
      }
      .tabBar(this.tabBarBuilder(0, '动态', $r('app.media.event'), $r('app.media.event')))

      TabContent() {
        NavDestination() {
          StarView()
        }
      }
      .tabBar(this.tabBarBuilder(1, 'Star', $r('app.media.star'), $r('app.media.star')))

      TabContent() {
        NavDestination() {
          Text('搜索')
        }
      }
      .tabBar(this.tabBarBuilder(2, '搜索', $r('app.media.search'), $r('app.media.search')))

      TabContent() {
        NavDestination() {
          Text('趋势')
        }
      }
      .tabBar(this.tabBarBuilder(3, '趋势', $r('app.media.star'), $r('app.media.star')))

      TabContent() {
        NavDestination() {
          Text('我的')
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
      }
      .tabBar(this.tabBarBuilder(4, '我', $r('app.media.me'), $r('app.media.me')))
    }
    .onChange((index: number) => {
      this.selectIndex = index
    })
    .scrollable(false)
    .animationDuration(0)
    .width('100%')
    .onAppear(() => {
      let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let val = data?.getSync('access_token', '')
      //刷新Token
    })
  }
}