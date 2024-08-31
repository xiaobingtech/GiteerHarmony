import { TrendSubView } from './TrendSubView'

@Component
export struct TrendView{
  build() {
    Navigation(){
      Tabs(){
        TabContent(){
          TrendSubView({
            type: 'featured'
          })
        }.tabBar('推荐')
        TabContent(){
          TrendSubView({
            type: 'popular'
          })
        }.tabBar('热门')
        TabContent(){
          TrendSubView({
            type: 'latest'
          })
        }.tabBar('最近更新')
      }
    }
    .title('趋势')
  }
}