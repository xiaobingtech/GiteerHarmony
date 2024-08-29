
@CustomDialog
@Component
export struct PersonalTokenDialog {
  @Link textValue: string
  controller?: CustomDialogController
  cancel: () => void = () => {

  }
  confirm: () => void = () => {

  }

  build() {
    Column() {
      Text('隐私声明：Giteer不会从您的Gitee账号收集任何信息，请您放心使用，如果需要访问私有仓库请点击底部登录按钮进行OAuth授权').margin({
        top: 10,
        bottom: 10
      })
      TextInput({ placeholder: '请输入私人令牌', text: this.textValue }).height(40).width('100%')
        .onChange((value: string) => {
          this.textValue = value
        })
        .margin({
          bottom: 10
        })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.cancel()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Black)
          .layoutWeight(1)
        Button('登录')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.confirm()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Red)
          .layoutWeight(1)
      }
    }.borderRadius(10)
    .padding(10)
    // 如果需要使用border属性或cornerRadius属性，请和borderRadius属性一起使用。
  }
}

@Entry
@Component
struct PersonTokenDialogExample {
  @State textValue: string = ''
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: PersonalTokenDialog({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
      textValue: $textValue,
    }),
    cancel: this.exitApp,
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
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  exitApp() {
    console.info('Click the callback in the blank area')
  }
  build() {
    Column() {
      Button('展示弹窗')
        .onClick(() => {
          if (this.dialogController != null) {
            this.dialogController.open()
          }
        }).backgroundColor(0x317aff)
    }.width('100%').margin({ top: 5 })
  }
}