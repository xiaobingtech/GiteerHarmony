import { IssueSubView } from './IssueSubView'


@Builder
export function IssueViewBuilder(name: string, param: Object) {
  IssueView()
}

@Component
struct IssueView{

  @State name: string = ''

  build() {
    NavDestination(){
      Tabs(){
        TabContent(){
          IssueSubView({
            state: 'open',
            name: this.name
          })
        }.tabBar('打开')
        TabContent(){
          IssueSubView({
            state: 'progressing',
            name: this.name
          })
        }.tabBar('进行中')
        TabContent(){
          IssueSubView({
            state: 'closed',
            name: this.name
          })
        }.tabBar('已关闭')
        TabContent(){
          IssueSubView({
            state: 'rejected',
            name: this.name
          })
        }.tabBar('已拒绝')
      }
    }
    .onReady((context) =>{
      this.name = context.pathInfo.param as string
    })
    .title('Issue')
  }
}