import { StarResponse } from '../../model/StarResponse'
import { StarItem } from './StarItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'
import { router } from '@kit.ArkUI'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { RepoPage } from '../repo/RepoPage'
import { MAX_OFFSET_Y, NORMAL_FONT_SIZE } from '../../common/CommonConstants'
import PutDownRefresh from '../../common/PutDownRefreshLayout'


@Component
export struct StarView{

  private currentOffsetY: number = 0;
  @State refreshStatus: boolean = false;
  @State refreshText: Resource = $r('app.string.refreshing_text');

  @State repos: Array<StarResponse> = []
  @State prev_id: number = 0

  derivedStack: DerivedNavPathStack = new DerivedNavPathStack();

  aboutToAppear(): void {
    this.derivedStack.setId('star stack');
  }

  @Builder
  pageMap(name: string) {
    RepoPage()
  }

  build() {
    Navigation(this.derivedStack){
      Row(){
        Column(){
          if (this.repos.length > 0) {
            if (this.refreshStatus) {
              PutDownRefresh({ refreshText: $refreshText })
            }
            List(){
              ForEach(this.repos, (item: StarResponse) => {
                StarItem({ item: item })
                  .onClick(() => {
                    if (this.derivedStack.size() == 0) {
                      this.derivedStack.pushPath({name: 'RepoPage', param: item})
                    }else{
                      this.derivedStack.replacePath({name: 'RepoPage', param: item})
                    }
                  })
              }, (item: StarResponse) => item.name)
            }
            .scrollBar(BarState.Off)
            .divider({ strokeWidth: 1, color: 0xFAFAFA, startMargin: 0, endMargin: 0 }) // 每行之间的分界线
            .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
            .onTouch((event?: TouchEvent) => {
              this.putDownRefresh(event);
            })
            Text($r('app.string.prompt_message')).fontSize(NORMAL_FONT_SIZE).fontColor($r('app.color.gray'))
          }else{
            Text('加载中...')
          }
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .navDestination(this.pageMap)
    .title('Star')
    .onAppear(() => {
      this.getStars()
    })
  }

  putDownRefresh(event?: TouchEvent): void {
    if (event === undefined) {
      return;
    }
    switch (event.type) {
    // Record the y-coordinate pressed by the finger.
      case TouchType.Down:
        this.currentOffsetY = event.touches[0].y;
        break;
      case TouchType.Move:
        // Determine whether to refresh based on the drop-down offset.
        this.refreshStatus = event.touches[0].y - this.currentOffsetY > MAX_OFFSET_Y;
        break;
      case TouchType.Cancel:
        break;
      case TouchType.Up:
        this.getStars()
        break;
      default:
        break;
    }
  }

  getStars() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let userData = preferences.getPreferencesSync(getContext(this), { name: 'user.db' })
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/users/${userData.getSync('login', '')}/starred?access_token=${tokenData.getSync('access_token', '')}&limit=100&sort=created&direction=desc`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<StarResponse> = JSON.parse(jsonStr)
        this.repos = result
      }
      this.refreshStatus = false
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}