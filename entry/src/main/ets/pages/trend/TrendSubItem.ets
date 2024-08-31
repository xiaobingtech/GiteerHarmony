import { StarResponse } from '../../model/StarResponse'

@Component
export struct TrendSubItem{
  @Prop item: StarResponse;
  build() {
    Row({space: 15}){
      Image(this.item.owner.portrait_url)
        .width(50)
        .borderRadius(25)
      Column({space: 5}){
        Text(this.item.name)
        Text(this.item.description)
          .maxLines(2)
        Text(this.item.updated_at)
      }
      .alignItems(HorizontalAlign.Start)
      .width('calc(100% - 70vp)')
    }
    .alignItems(VerticalAlign.Top)
    .padding(15)
  }
}