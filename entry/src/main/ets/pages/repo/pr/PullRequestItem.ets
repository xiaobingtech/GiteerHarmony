import { PullRequestModel } from '../../../model/PullRequestModel'

@Component
export struct PullRequestItem{
  @Prop item: PullRequestModel

  build() {
    Column({space: 5}){
      Text(this.item.title)
        .maxLines(2)
      Row(){
        Text(this.item.updated_at)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(15)
  }
}