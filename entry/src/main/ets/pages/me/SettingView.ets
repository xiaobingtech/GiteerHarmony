import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'

@Builder
export function SettingViewBuilder(name: string, param: Object) {
  SettingView()
}

@Component
struct SettingView{
  build() {
    NavDestination(){
      Column(){
        List(){
          ListItem(){
            Row(){
              Text('退出登录')
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .width('100%')
          }
          .onClick(() => {
            let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
            data.putSync('access_token', '')
            data.putSync('refresh_token', '')
            data.flush()
            router.replaceUrl({
              url: "pages/Index"
            })
          })
          .padding(15)
        }
      }
    }
    .title('设置')
  }
}