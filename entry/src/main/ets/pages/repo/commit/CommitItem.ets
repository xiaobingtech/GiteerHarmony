import { CommitModel } from '../../../model/CommitModel'

@Component
export struct CommitItem{
  @Prop item: CommitModel

  build() {
    Column({space: 5}){
      Text(this.item.commit.message)
        .maxLines(2)
      Row(){
        Text(this.item.commit.author.date)
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding(15)
  }
}