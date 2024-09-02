import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';

@Builder
export function RepoTreePageBuilder(name: string, param: Object) {
  RepoTreePage()
}

@Component
export struct RepoTreePage {

  @State item: StarResponse = new StarResponse()

  derivedStack: DerivedNavPathStack | null = null;

  build() {
    NavDestination(){
      Column(){
        Text('RepoTreePage')
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context) => {
      this.item = context.pathInfo.param as StarResponse
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .title(this.item.humman_name)
  }
}