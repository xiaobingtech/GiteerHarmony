import { IssueModel } from '../../../model/IssueModel'

@Component
export struct IssueItem{
  @Prop item: IssueModel

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