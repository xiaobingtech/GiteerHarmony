@Component
export struct TrendView{
  build() {
    Tabs(){
      TabContent(){

      }.tabBar('推荐')
      TabContent(){

      }.tabBar('热门')
      TabContent(){

      }.tabBar('最近更新')
    }
  }
}