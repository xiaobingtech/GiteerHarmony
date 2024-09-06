import { MsgModelList } from '../../../model/MsgModel'

@Component
export struct MsgItem{
  @Prop item: MsgModelList

  build() {
    Row({space: 15}){
      Image(this.item.sender.avatar_url)
        .width(50)
        .borderRadius(25)
      Column({space: 5}){
        Text(this.item.sender.name)
        Text(this.item.content)
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
      .width('calc(100% - 70vp)')
    }
    .alignItems(VerticalAlign.Top)
    .padding(15)
  }
}