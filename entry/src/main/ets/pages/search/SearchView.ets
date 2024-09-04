import { StarView } from '../star/StarView'
import { UserListView } from './UserListView'

@Component
export struct SearchView {
  controller: SearchController = new SearchController()

  @State q: string = ''

  build() {
    Navigation(){
      Row(){
        Column(){
          Search({
            placeholder: '请输入搜索内容',
            controller: this.controller
          })
            .onSubmit((value) => {
              this.q = value
            })
            .margin(15)
          Tabs(){
            TabContent(){

            }.tabBar('仓库')
            TabContent(){
              UserListView({q: this.q})
            }.tabBar('用户')
          }
        }
      }
    }
    .title('搜索')
  }
}