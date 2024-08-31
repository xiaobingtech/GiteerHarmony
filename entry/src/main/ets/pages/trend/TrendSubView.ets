import { StarResponse } from '../../model/StarResponse'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { TrendSubItem } from './TrendSubItem'


@Component
export struct TrendSubView{

  @Prop type: string = ''

  @State repos: Array<StarResponse> = []
  @State prev_id: number = 0
  @State progress: number = 50

  build() {
    Row(){
      Column(){
        if (this.repos.length > 0) {
          List(){
            ForEach(this.repos, (item: StarResponse) => {
              TrendSubItem({ item: item })
                .onClick(() => {

                })
            }, (item: StarResponse) => item.name)
          }
          .scrollBar(BarState.Off)
          .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
        }else{
          Text('加载中...')
        }
      }
      .width('100%')
      .height('100%')
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
        let result: Array<StarResponse> = JSON.parse(jsonStr)
        this.repos = result
      }
      this.progress = 100
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.progress = 100
    })
  }
}