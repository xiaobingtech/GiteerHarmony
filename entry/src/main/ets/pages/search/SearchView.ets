import { StarView } from '../star/StarView'

@Component
export struct SearchView {
  controller: SearchController = new SearchController()
  build() {
    Navigation(){
      Column(){
        Search({
          placeholder: '请输入搜索内容',
          controller: this.controller
        })
          .onSubmit(() => {

          })
          .margin(15)
        Tabs(){
          TabContent(){

          }.tabBar('仓库')
          TabContent(){

          }.tabBar('用户')
        }
      }
    }
    .title('搜索')
  }
}