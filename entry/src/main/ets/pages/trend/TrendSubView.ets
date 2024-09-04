import { RepoModel } from '../../model/RepoModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { TrendSubItem } from './TrendSubItem'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'


@Component
export struct TrendSubView{

  @Prop type: string = ''

  @State repos: Array<RepoModel> = []
  @State prev_id: number = 0
  @State progress: number = 50

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column(){
      if (this.repos.length > 0) {
        List(){
          ForEach(this.repos, (item: RepoModel) => {
            TrendSubItem({ item: item })
              .onClick(() => {
                if (this.derivedStack != null) {
                  if (this.derivedStack.size() == 0) {
                    this.derivedStack.pushPath({name: 'RepoPage', param: item.path_with_namespace})
                  }else{
                    this.derivedStack.replacePath({name: 'RepoPage', param: item.path_with_namespace})
                  }
                }
              })
          }, (item: RepoModel) => item.name)
        }
        .scrollBar(BarState.Off)
        .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
        .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
        .width('100%')
        .height('100%')
      }else{
        LoadingProgress()
          .width('25%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.getStars()
    })
  }

  getStars() {
    const session = rcp.createSession()
    session.get(`https://gitee.com/api/v3/projects/${this.type}`).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoModel> = JSON.parse(jsonStr)
        this.repos = result
      }
      this.progress = 100
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.progress = 100
    })
  }
}