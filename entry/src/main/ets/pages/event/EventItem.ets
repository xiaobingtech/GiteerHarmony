import { EventResponse } from '../../model/EventResponse';

@Component
export struct EventItem {
  @Prop item: EventResponse;
  build() {
    Row({space: 15}){
      Image(this.item.actor.avatar_url)
        .width(50)
        .borderRadius(25)
      Text(this.item.actor.name)
    }
    .alignItems(VerticalAlign.Top)
    .padding(15)
  }
}