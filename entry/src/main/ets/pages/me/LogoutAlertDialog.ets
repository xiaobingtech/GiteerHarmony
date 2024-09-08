@CustomDialog
@Component
export struct LogoutAlertDialog {
  controller?: CustomDialogController
  cancel: () => void = () => {

  }
  confirm: () => void = () => {

  }

  build() {
    Column() {
      Text('你确定要退出吗？').margin({
        top: 15,
        bottom: 15
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
        Button('确定')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.confirm()
            }
          }).backgroundColor(0xffffff).fontColor(Color.Red)
          .layoutWeight(1)
      }
    }.borderRadius(10)
    .padding(15)
    // 如果需要使用border属性或cornerRadius属性，请和borderRadius属性一起使用。
  }
}