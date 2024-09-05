import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';

@Builder
export function VideoViewBuilder(name: string, param: Object) {
  VideoView()
}

@Component
export struct VideoView {

  @State url: string = ''

  derivedStack: DerivedNavPathStack | null = null;

  controller: VideoController = new VideoController()

  build() {
    NavDestination(){
      Column(){
        Video({
          src: this.url,
          controller:this.controller
        })
          .autoPlay(true)
          .objectFit(ImageFit.Auto)
          .width('100%')
          .height(300)
          .onStart(() => {
            console.info('onStart')
          })
          .onPause(() => {
            console.info('onPause')
          })
          .onFinish(() => {
            console.info('onFinish')
          })
          .onError(() => {
            console.info('onError')
          })
          .onStop(() => {
            console.info('onStop')
          })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context) =>{
      this.url = context.pathInfo.param as string
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .title(this.url)
  }
}