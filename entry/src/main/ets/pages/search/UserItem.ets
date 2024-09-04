import { UserModel } from '../../model/UserModel'

@Component
export struct UserItem{

@Prop item:UserModel

  build() {
    Row({ space: 15 }) {
      Image(this.item.avatar_url)
        .width(50)
        .borderRadius(25)
      Column({ space: 5 }) {
        Text(this.item.name)
          .maxLines(2)
        Text(this.item.created_at)
      }
      .alignItems(HorizontalAlign.Start)
      .width('calc(100% - 70vp)')
    }
    .alignItems(VerticalAlign.Top)
    .padding(15)
  }
}