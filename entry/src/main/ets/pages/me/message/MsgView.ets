import { DerivedNavPathStack } from '../../../common/DerivedNavPathStack'
import { MsgModel, MsgModelList } from '../../../model/MsgModel'
import { MsgItem } from './MsgItem'
import { rcp } from '@kit.RemoteCommunicationKit'
import { preferences } from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export struct MsgView{
  @State page: number = 1
  @State isRefreshing: boolean = true
  @State isFooterRefreshing: boolean = false
  @State msgs: Array<MsgModelList> = []
  @State latestPerGroup: Array<MsgModelList> = []
  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column() {
      if (!this.isRefreshing) {
        Refresh({ refreshing: $$this.isRefreshing }) {
          List() {
            ForEach(this.latestPerGroup, (item: MsgModelList) => {
              MsgItem({ item: item })
                .onClick(() => {

                })
            }, (item: MsgModelList) => `${item.id}`)
          }
          .scrollBar(BarState.Off)
          .divider({
            strokeWidth: 1,
            color: 0xFAFAFA,
            startMargin: 0,
            endMargin: 0
          }) // 每行之间的分界线
          .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
          .width('100%')
          .height('100%')
          .onReachEnd(() => {
            this.footerRefresh()
          })
        }
        .onRefreshing(() => {
          this.headerRefresh()
        })
        .refreshOffset(64)
        .pullToRefresh(true)
      } else {
        LoadingProgress()
          .width(100)
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh() {
    this.page = 1
    this.getMsgs()
  }

  footerRefresh() {
    if (this.isFooterRefreshing || this.msgs.length < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page++
    this.getMsgs()
  }

  getMsgs() {
    const session = rcp.createSession()
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/notifications/messages?access_token=${tokenData.getSync('access_token', '')}&per_page=100&page=${this.page}`
    console.log('当前请求URL', url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: MsgModel = JSON.parse(jsonStr)



        if (this.page == 1) {
          this.msgs = result.list
        } else {
          this.msgs.push(...result.list)
        }

        // 分组
        const groupedBySenderId = this.msgs.reduce<Record<number, MsgModelList[]>>((acc, currentValue) => {
          const senderId = currentValue.sender.id;
          if (!acc[senderId]) {
            acc[senderId] = [];
          }
          acc[senderId].push(currentValue);
          return acc;
        }, {});

        // 对每个分组找到最新的元素
        const latestPerGroup = Object.values(groupedBySenderId).map(group => {
          // 假设 'updated_at' 是可以直接比较的字符串，例如ISO 8601格式
          return group.sort((a, b) => b.updated_at.localeCompare(a.updated_at))[0];
        });

        this.latestPerGroup = latestPerGroup

      }



      this.isRefreshing = false
      this.isFooterRefreshing = false
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isRefreshing = false
      this.isFooterRefreshing = false
    })
  }
}