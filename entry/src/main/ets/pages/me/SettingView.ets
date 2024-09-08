import { preferences } from '@kit.ArkData'
import { router } from '@kit.ArkUI'
import { LogoutAlertDialog } from './LogoutAlertDialog'

@Builder
export function SettingViewBuilder(name: string, param: Object) {
  SettingView()
}

@Component
struct SettingView{

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: LogoutAlertDialog ({
      cancel: ()=> {

      },
      confirm: ()=> {
        let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
        data.putSync('access_token', '')
        data.putSync('refresh_token', '')
        data.flush()
        router.replaceUrl({
          url: "pages/Index"
        })
      },
    }),
    cancel: () => {

    },
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

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
            this.dialogController?.open()
          })
          .padding(15)
        }
      }
    }
    .title('设置')
  }
}