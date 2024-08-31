import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';

@Entry
@Component
export struct RepoPage {
  @State item: StarResponse = StarResponse()

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  build() {
    NavDestination(){
      Row({space: 15}){
        Image(this.item.owner.avatar_url)
          .width(50)
          .borderRadius(25)
        Column({space: 5}){
          Text(this.item.name)
            .maxLines(2)
          Text(this.item.description)
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)
        .width('calc(100% - 70vp)')
      }
      .alignItems(VerticalAlign.Top)
      .padding(15)
    }
    .onReady((context) => {
      item = context.pathInfo.param
    })
  }
}