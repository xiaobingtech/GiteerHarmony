import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { RepoModel } from '../../model/RepoModel';
import { promptAction, router} from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoTreeModel } from '../../model/RepoTreeModel';
import { RepoTreeParam } from './RepoTreeView';
import { efRcpClientApi } from '@yunkss/ef_rcp';

@Builder
export function RepoFolderViewBuilder(name: string, param: Object) {
  RepoFolderView()
}

@Component
export struct RepoFolderView {

  @State name: string|undefined = ''
  @State path: string = ''
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
      this.path = param.path
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.getContents()
    })
    .title(this.path)
  }

  async getContents() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/contents/${this.path}?access_token=${tokenData.getSync('access_token', '')}&ref=${this.ref}`
    let response = await efRcpClientApi.get<Array<RepoTreeModel>>({
      url: url
    })
    if (response.error) {
      this.isLoading = false
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    this.result = response.data!
    this.isLoading = false
  }

  encodeNonChineseCharacters(str: string): string {
    // 使用正则表达式匹配非汉字字符
    return str.replace(/[\u3400-\u9FFF\u3000-\u303f\uff00-\uffef]/g, (match) => {
      // 对匹配到的非汉字字符进行编码
      return encodeURIComponent(match);
    });
  }
}