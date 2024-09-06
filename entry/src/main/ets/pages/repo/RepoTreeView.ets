import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { RepoModel } from '../../model/RepoModel';
import { router} from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoTreeModel } from '../../model/RepoTreeModel';

@Builder
export function RepoTreeViewBuilder(name: string, param: Object) {
  RepoTreeView()
}

@Component
export struct RepoTreeView {

  @State item: RepoModel|null = null
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
                .height(44)
                .padding(15)
                .onClick((event) =>{
                  if (item.type == 'dir') {
                    this.getContents(item.path, item)
                  }else{
                    //打开文件
                    let strings = item.download_url.split('/')
                    let fileName = strings[strings.length - 1]
                    let fileNameStrs = fileName.split('.')
                    let suffix = fileNameStrs[fileNameStrs.length - 1]
                    let encodeUrl = encodeURIComponent(fileName)

                    // 获取除最后一个元素外的所有元素
                    let reducedArray: string[] = strings.slice(0, strings.length - 1);

                    // 将剩下的元素以 "/" 拼接
                    let joinedString: string = reducedArray.join("/");

                    // 将剩下的元素和字符串B用 "/" 拼接
                    let result: string = joinedString + "/" + encodeUrl;


                    if (suffix == 'jpg' || suffix == 'png') {
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
      this.item = context.pathInfo.param as RepoModel
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      this.getContents('')
    })
    .title('仓库Tree')
  }

  getContents(path: string, item: RepoTreeModel|null = null) {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.item?.full_name}/contents/${path}?access_token=${tokenData.getSync('access_token', '')}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoTreeModel> = JSON.parse(jsonStr)
        if (item == null) {
          this.result = result
        }else{
          item.child = result
        }
        this.isLoading = false
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isLoading = false
    })
  }
}