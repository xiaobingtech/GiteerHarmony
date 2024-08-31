import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';

@Entry
@Component
export struct RepoPage {
  @State item: StarResponse = new StarResponse()

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  build() {
    NavDestination(){
      Row({space: 15}){
        Image(this.item.owner.avatar_url)
          .width(50)
          .borderRadius(25)
        Column({space: 5}){
          Text(this.item.name)
          Text(this.item.description)
          Text(this.item.updated_at)
        }
        .alignItems(HorizontalAlign.Start)
        .width('calc(100% - 70vp)')
      }
      .alignItems(VerticalAlign.Top)
      .padding(15)
    }
    .onReady((context) => {
      this.item = context.pathInfo.param as StarResponse
    })
    .title('仓库')
  }
}