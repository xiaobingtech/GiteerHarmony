import { it } from '@ohos/hypium';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { preferences } from '@kit.ArkData';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoModel } from '../../model/RepoModel';
import { ReadmeModel } from '../../model/ReadmeModel';
import { Base64 } from '@ohos/base64';
import { lvMarkdownIn } from '@luvi/lv-markdown-in'
import util from '@ohos.util';


@Builder
export function RepoPageBuilder(name: string, param: Object) {
  RepoPage()
}

@Component
export struct RepoPage {
  @State item: RepoModel|null = null
  @State name: string = ''
  @State ref: string = ''
  @State readme: ReadmeModel|null = null
  @State content: string = ''

  private derivedStack: DerivedNavPathStack | null = null;

  @Builder NavigationMenus() {
    Row() {
      SymbolGlyph($r(this.item?.stared ? 'sys.symbol.star' : 'sys.symbol.star_fill'))
        .fontSize(24)
    }
    .padding(15)
    .onClick(() => {
      const session = rcp.createSession()
      let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let url = `https://gitee.com/api/v5/user/starred/${this.item?.full_name}?access_token=${tokenData.getSync('access_token', '')}`
      console.log('当前URL:',url)
      if (this.item?.stared) {
        session.put(url).then((response) => {
          console.info(`Response succeeded: ${response}`);
          // this.item?.stared = false
        }).catch((err: BusinessError) => {
          console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
        })
      }else{
        session.delete(url).then((response) => {
          console.info(`Response succeeded: ${response}`);
          // this.item?.stared = true
        }).catch((err: BusinessError) => {
          console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
        })
      }
    })
  }

  build() {
    NavDestination(){
      if (this.item?.name != '') {
        Scroll(){
          Column(){
            Row({space: 15}){
              if (this.item?.owner.avatar_url != '') {
                Image(this.item?.owner.avatar_url)
                  .width(50)
                  .borderRadius(25)
              }else{
                Image('https://gitee.com/assets/no_portrait.png')
                  .width(50)
                  .borderRadius(25)
              }
              Column({space: 5}){
                Text(this.item?.human_name)
                Text(this.item?.description)
                Text(this.item?.updated_at)
              }
              .alignItems(HorizontalAlign.Start)
              .width('calc(100% - 70vp)')
            }
            .alignItems(VerticalAlign.Top)
            .padding(15)
            Divider()
            Row(){
              Text('代码')
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .onClick(() => {
              if (this.derivedStack) {
                this.derivedStack.pushPath({name: 'RepoTreePage', param: this.item})
              }
            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            Row(){
              Text('README')
              Blank()
              SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            }
            .onClick(() => {

            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            if (this.readme != null) {
              lvMarkdownIn({text: this.content})
                .padding(15)
            }
          }
        }
      }else{
        LoadingProgress()
          .width(100)
      }
    }
    .onReady((context) => {
      console.log(context.pathInfo.param as string)
      this.name = context.pathInfo.param as string
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.getRepo()
      this.getRepoReadme()
    })
    .title('仓库')
    .menus(this.NavigationMenus())
  }

  getRepo() {
    const session = rcp.createSession()
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}?access_token=${tokenData.getSync('access_token', '')}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: RepoModel = JSON.parse(jsonStr)
        this.item = result
        this.ref = result.default_branch
      }

    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }

  getRepoReadme() {
    const session = rcp.createSession()
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/readme?access_token=${tokenData.getSync('access_token', '')}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: ReadmeModel = JSON.parse(jsonStr)
        this.readme = result

        let textDecoderOptions: util.TextDecoderOptions = {
          fatal: false,
          ignoreBOM : true
        }
        let decodeToStringOptions: util.DecodeToStringOptions = {
          stream: false
        }
        let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
        let resultA = Base64.decode(this.readme?.content);
        let retStr = textDecoder.decodeToString(resultA, decodeToStringOptions);
        this.content = retStr
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}