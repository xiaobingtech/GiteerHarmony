import { SearchRepoListView } from './SearchRepoListView'
import { SearchUserListView } from './SearchUserListView'

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
              SearchRepoListView({q: this.q})
            }.tabBar('仓库')
            TabContent(){
              SearchUserListView({q: this.q})
            }.tabBar('用户')
          }
        }
      }
    }
    .title('搜索')
  }
}