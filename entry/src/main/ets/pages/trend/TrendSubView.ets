import { RepoModel } from '../../model/RepoModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { TrendSubItem } from './TrendSubItem'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'
import { efRcpClientApi } from '@yunkss/ef_rcp'
import { promptAction } from '@kit.ArkUI'


@Component
export struct TrendSubView{

  @State page: number = 1

  @State isRefreshing: boolean = true
  @State isFooterRefreshing:boolean = false

  @Prop type: string = ''

  @State repos: Array<RepoModel> = []
  @State prev_id: number = 0

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  build() {
    Column(){
      if (this.isRefreshing && this.repos.length == 0) {
        LoadingProgress()
          .width(100)
          .height('100%')
      }else{
        Refresh({refreshing:$$this.isRefreshing}){
          List(){
            ForEach(this.repos, (item: RepoModel) => {
              TrendSubItem({ item: item })
                .onClick(() => {
                  if (this.derivedStack != null) {
                    if (this.derivedStack.size() == 0) {
                      this.derivedStack.pushPath({name: 'RepoView', param: item.path_with_namespace})
                    }else{
                      this.derivedStack.replacePath({name: 'RepoView', param: item.path_with_namespace})
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
          .onReachEnd(() =>{
            this.footerRefresh()
          })
        }
        .onRefreshing(() => {
          this.headerRefresh()
        })
        .refreshOffset(64)
        .pullToRefresh(true)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.headerRefresh()
    })
  }

  headerRefresh(){
    this.page = 1
    this.getProjects()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.repos.length  < 20) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getProjects()
  }

  async getProjects() {
    let url = `api/v3/projects/${this.type}?page=${this.page}`
    let response = await efRcpClientApi.get<Array<RepoModel>>({
      url: url
    })
    if (response.error) {
      this.isRefreshing = false
      this.isFooterRefreshing = false
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data
    if (this.page == 1) {
      this.repos = result!
    }else{
      this.repos.push(...result!)
    }
    this.isRefreshing = false
    this.isFooterRefreshing = false
  }
}