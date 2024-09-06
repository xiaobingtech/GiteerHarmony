import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';

@Builder
export function VideoViewBuilder(name: string, param: Object) {
  VideoView()
}

@Component
export struct VideoView {

  @State url: string = ''
  @State title: string = ''

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
          .onSeeking((value) =>{
            console.log('onSeeking', value.time)
          })
          .onSeeked((value) =>{
            console.log('onSeeked', value.time)
          })
      }
      .width('100%')
      .height('100%')
    }
    .onReady((context) =>{
      this.url = context.pathInfo.param as string
      this.derivedStack = context.pathStack as DerivedNavPathStack

      let strings = this.url.split('/')
      let fileName = strings[strings.length - 1]
      this.title = decodeURIComponent(fileName)

    })
    .title(this.title)
  }
}