import { router } from '@kit.ArkUI';
import { PersonalTokenDialog } from './PersonalTokenDialog';
import { preferences } from '@kit.ArkData';
import { DerivedNavPathStack } from '../common/DerivedNavPathStack';
import { Constraints } from '../Constraints';
import { WebPage } from './WebPage';

@Entry
@Component
struct Index {

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  @State textValue: string = 'e5a79f99737b95e26f73793ff242180b'
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: PersonalTokenDialog ({
      cancel: ()=> {

      },
      confirm: ()=> {
        // e5a79f99737b95e26f73793ff242180b
        //存储数据
        let data = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
        data?.putSync('access_token', this.textValue)
        data.flush()
        router.replaceUrl({
          url: 'pages/TabPage'
        })
      },
      textValue: $textValue,
    }),
    cancel: () => {

    },
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
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
    this.derivedStack.setId('star stack');
  }

  @Builder
  pageMap(name: string) {
    WebPage()
  }

  build() {
    Navigation(this.derivedStack){
      Column({
        space: 15
      }){
        Button('私人令牌')
          .backgroundColor(Color.Transparent)
          .fontColor('#b12c25')
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open()
            }
          })
        Button('登录')
          .backgroundColor('#b12c25')
          .width('100%')
          .onClick(() => {
            let url = `https://gitee.com/oauth/authorize?client_id=${Constraints.client_id}&redirect_uri=${Constraints.redirect_uri}&response_type=code`
            console.log('当前加载URL:'+url)
            this.derivedStack.pushPath({name: 'WebPage', param: url})
          })
      }
      .height('100%')
      .width('100%')
      .padding(15)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.End)
    }
    .title('登录Gitee（码云）')
    .navDestination(this.pageMap)
  }
}