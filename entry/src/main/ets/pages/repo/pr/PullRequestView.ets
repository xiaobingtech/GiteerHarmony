import { PullRequestSubView } from './PullRequestSubView'


@Builder
export function PullRequestViewBuilder(name: string, param: Object) {
  PullRequestView()
}

@Component
struct PullRequestView{

  @State name: string = ''

  build() {
    NavDestination(){
      Tabs(){
        TabContent(){
          PullRequestSubView({
            state: 'open',
            name: this.name
          })
        }.tabBar('打开')
        TabContent(){
          PullRequestSubView({
            state: 'merged',
            name: this.name
          })
        }.tabBar('已合并')
        TabContent(){
          PullRequestSubView({
            state: 'closed',
            name: this.name
          })
        }.tabBar('已关闭')
      }
    }
    .onReady((context) =>{
      this.name = context.pathInfo.param as string
    })
    .title('PullRequest')
  }
}