import { lvMarkdownIn } from '@luvi/lv-markdown-in';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { preferences } from '@kit.ArkData';
import { promptAction } from '@kit.ArkUI';
import { efRcpClientApi } from '@yunkss/ef_rcp';

@Builder
export function CodeViewBuilder(name: string, param: Object) {
  CodeView()
}

@Component
export struct CodeView {

  @State url: string = ''
  @State title: string = ''
  @State content: string = ''

  derivedStack: DerivedNavPathStack | null = null;

  build() {
    NavDestination(){
      Column(){

      }
      .width('100%')
      .height('100%')
    }
    .onReady((context) =>{
      this.url = context.pathInfo.param as string
      this.derivedStack = context.pathStack as DerivedNavPathStack

      let strings = this.url.split('/')
      let fileName = strings[strings.length - 1]
      this.title = decodeURIComponent(fileName)

    })
    .onAppear(() => {
      this.getContent()
    })
    .title(this.title)
  }

  async getContent() {
    let response = await efRcpClientApi.get<string>({
      url: this.url
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    this.content = response.data!!
  }
}