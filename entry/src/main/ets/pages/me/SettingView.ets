import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'

@Builder
export function SettingViewBuilder(name: string, param: Object) {
  SettingView()
}

@Component
struct SettingView{
  build() {
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
}