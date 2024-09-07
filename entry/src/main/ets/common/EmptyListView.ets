import { ComposeTitleBar } from '@ohos.arkui.advanced.ComposeTitleBar'

@Preview
@Component
export struct EmptyListView{

  retryClick: () => void = () => {

  }

  build() {
    Row(){
      Column({space: 15}){
        Text('暂时没有数据')
        Button('重试')
          .onClick(() => {
            this.retryClick()
          })
      }.alignItems(HorizontalAlign.Center)
      .width('100%')
    }
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height('100%')
  }
}