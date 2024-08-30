import { StarResponse } from '../../model/StarResponse'

@Component
export struct StarItem{
  @Prop item: StarResponse;
  build() {
    Row({space: 15}){
      Image(this.item.owner.avatar_url)
        .width(50)
        .borderRadius(25)
      Column({space: 5}){
        Text(this.item.name)
        Text(this.item.description)
          .maxLines(2)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(VerticalAlign.Top)
    .padding({left: 15, right: 15, top: 15, bottom: 15})
  }
}