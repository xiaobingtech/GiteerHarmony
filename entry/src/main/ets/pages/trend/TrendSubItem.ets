import { RepoModel } from '../../model/RepoModel'

@Component
export struct TrendSubItem{
  @Prop item: RepoModel;
  build() {
    Row({space: 15}){
      if (!this.item.owner.portrait_url.startsWith('no_portrait.png')) {
        Image(this.item.owner.portrait_url)
          .width(50)
          .borderRadius(25)
      }else{
        Image('https://gitee.com/assets/no_portrait.png')
          .width(50)
          .borderRadius(25)
      }
      Column({space: 5}){
        Text(this.item.name_with_namespace)
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