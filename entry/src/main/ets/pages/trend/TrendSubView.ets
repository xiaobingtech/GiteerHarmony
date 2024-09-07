import { RepoModel } from '../../model/RepoModel'
import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { TrendSubItem } from './TrendSubItem'
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack'


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
      if (!this.isRefreshing) {
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
      }else{
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

  headerRefresh(){
    this.page = 1
    this.getProjects()
  }

  footerRefresh(){
    if (this.isFooterRefreshing || this.repos.length  < 100) {
      return
    }
    this.isFooterRefreshing = true
    this.page ++
    this.getProjects()
  }

  getProjects() {
    const session = rcp.createSession()
    let url = `https://gitee.com/api/v3/projects/${this.type}?page=${this.page}`
    console.log('当前请求URL', url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoModel> = JSON.parse(jsonStr)
        if (this.page == 1) {
          this.repos = result
        }else{
          this.repos.push(...result)
        }
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