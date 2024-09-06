import { ImagePreView, ImagePreViewOption } from '@rv/image-preview/Index'
import { promptAction, router } from '@kit.ArkUI'

@Entry
@Component
struct ImagePreViewPage {
  images: ResourceStr[] = router.getParams() as ResourceStr[]
  @State imagePreViewOption: ImagePreViewOption = new ImagePreViewOption()

  aboutToAppear(): void {
    this.imagePreViewOption
      .setImage(this.images)
      .setLongPressListener((_, index) => {
        promptAction.showToast({ message: "长按" + index.toString() })
      })
      .setOnPullDownListener((index) => {
        router.back()
      })
      .setOnClickListener((_, index) => {
        promptAction.showToast({ message: "单击" + index.toString() })
      })
      .setAboutToTurnPageListener((page) => {
        promptAction.showToast({ message: "即将去往" + page.toString() })
      })
      .setCachedCount(0)
      .setMinScale(0.5)
      .setBackgroundColor(Color.White)
      .setFlipListener(() => {
        promptAction.showToast({
          message: "翻页"
        })
      })
      .setSharedIdGenerate((item,index) => JSON.stringify(item) + index)
    // .setIndicatorType(IndicatorType.None)
  }

  build() {
    Column() {
      ImagePreView({ option: this.imagePreViewOption })
    }
    .width("100%")
    .height("100%")
  }
}