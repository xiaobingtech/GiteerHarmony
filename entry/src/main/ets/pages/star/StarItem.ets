import { RepoModel } from '../../model/RepoModel';

@Component
export struct StarItem{
  @Prop item: RepoModel;
  build() {
    Row({space: 15}){
      Image(this.item.owner.avatar_url)
        .width(50)
        .borderRadius(25)
      Column({space: 5}){
        Text(this.item.human_name)
          .maxLines(2)
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