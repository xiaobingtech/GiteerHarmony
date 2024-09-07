import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { RepoModel } from '../../model/RepoModel';
import { router} from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoTreeModel } from '../../model/RepoTreeModel';

export class RepoTreeParam {
  name: string|undefined = ''
  ref: string = ''
  path: string = ''
}

@Builder
export function RepoTreeViewBuilder(name: string, param: Object) {
  RepoTreeView()
}

@Component
export struct RepoTreeView {

  @State name: string|undefined = ''
  @State ref: string = ''

  @State isLoading:boolean = true

  derivedStack: DerivedNavPathStack | null = null;

  @State result: Array<RepoTreeModel> = []

  aboutToAppear(): void {

  }

  build() {
    NavDestination(){
      Column(){
        if (this.isLoading) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          List(){
            ForEach(this.result, (item: RepoTreeModel) => {
              ListItem() {
                Row(){
                  Image(item.type == 'dir' ?
                    $r('app.media.folder') : $r('app.media.file'))
                    .width(22)
                  Blank().width(15)
                  Text(item.name)
                    .width('calc(100% - 67vp)')
                  Blank()
                  if (item.type == 'dir') {
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                  }
                }
                .width('100%')
                .height(44)
                .padding(15)
                .onClick((event) =>{
                  if (item.type == 'dir') {
                    let param = new RepoTreeParam()
                    param.name = this.name
                    param.ref = this.ref
                    param.path = item.path
                    this.derivedStack?.pushPath({name: 'RepoFolderView', param: param})
                  }else{
                    //打开文件

                    let strings = item.download_url.split('/')
                    let fileName = strings[strings.length - 1]
                    let fileNameStrs = fileName.split('.')
                    let suffix = fileNameStrs[fileNameStrs.length - 1]

                    let result = this.encodeNonChineseCharacters(item.download_url)
                    console.log('当前文件地址', result)
                    if (suffix == 'jpg' || suffix == 'png' || suffix == 'gif' || suffix == 'webp') {
                      router.pushUrl({
                        url: 'pages/repo/ImagePreviewPage',
                        params: [result]
                      })
                    }else if (suffix == 'mp4') {
                      this.derivedStack?.pushPath({name:'VideoView', param: result})
                    }
                  }
                })
              }
            }, (item: RepoTreeModel) => item.sha)
          }
            .width('100%')
            .height('100%')
        }
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context) => {
      let param = context.pathInfo.param as RepoTreeParam
      this.name = param.name
      this.ref = param.ref
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.getContents()
    })
    .title('仓库Tree')
  }

  getContents() {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/contents?access_token=${tokenData.getSync('access_token', '')}&ref=${this.ref}`
    console.log('当前请求URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoTreeModel> = JSON.parse(jsonStr)
        this.result = result
        this.isLoading = false
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isLoading = false
    })
  }

  encodeNonChineseCharacters(str: string): string {
    // 使用正则表达式匹配非汉字字符
    return str.replace(/[\u3400-\u9FFF\u3000-\u303f\uff00-\uffef]/g, (match) => {
      // 对匹配到的非汉字字符进行编码
      return encodeURIComponent(match);
    });
  }
}