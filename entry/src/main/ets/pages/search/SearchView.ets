
@Component
export struct SearchView {
  controller: SearchController = new SearchController()
  build() {
    Row(){
      Search({
        placeholder: '请输入搜索内容',
        controller: this.controller
      })
        .onSubmit(() => {

        })
        .margin(15)
    }
  }
}