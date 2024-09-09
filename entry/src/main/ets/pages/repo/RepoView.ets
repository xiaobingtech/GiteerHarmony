import { it } from '@ohos/hypium';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { preferences } from '@kit.ArkData';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoModel } from '../../model/RepoModel';
import { ReadmeModel } from '../../model/ReadmeModel';
import { Base64 } from '@ohos/base64';
import { lvMarkdownIn, mdRegister  } from '@luvi/lv-markdown-in'
import util from '@ohos.util';
import { promptAction, router, SelectDialog } from '@kit.ArkUI';
import { BranchModel } from '../../model/BranchModel';
import { RepoTreeParam } from './RepoTreeView';
import { efRcpClientApi, EfRcpResponse } from '@yunkss/ef_rcp';


@Builder
export function RepoViewBuilder(name: string, param: Object) {
  RepoView()
}

@Component
export struct RepoView {
  @State item: RepoModel|null = null
  @State name: string = ''
  @State ref: string = ''
  @State readme: ReadmeModel|null = null
  @State content: string = ''
  @State branch: Array<BranchModel> = []

  private derivedStack: DerivedNavPathStack | null = null;

  @Builder NavigationMenus() {
    Row() {
      SymbolGlyph($r(this.item?.stared ? 'sys.symbol.star_fill' : 'sys.symbol.star'))
        .fontSize(24)
    }
    .padding(15)
    .onClick(async () => {
      let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
      let url = `https://gitee.com/api/v5/user/starred/${this.item?.full_name}?access_token=${tokenData.getSync('access_token', '')}`
      let response: EfRcpResponse<RepoModel>|null = null
      if (this.item?.stared) {
        response = await efRcpClientApi.put<RepoModel>({
					url: url,
					query: undefined
				})
      }else{
        response = await efRcpClientApi.delete<RepoModel>({
          url: url
        })
      }
      if (response.error) {
        promptAction.showToast({
          message: response.error.message
        })
        return
      }
      this.getRepo()
    })
  }

  build() {
    NavDestination(){
      if (this.item) {
        Scroll(){
          Column(){
            Row({space: 15}){
              if (this.item?.owner.avatar_url) {
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
                let param = new RepoTreeParam()
                param.name = this.item?.full_name
                param.ref = this.ref
                this.derivedStack.pushPath({name: 'RepoTreeView', param: param})
              }
            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            Row(){
              Text('提交')
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .onClick(() => {
              if (this.derivedStack) {
                this.derivedStack.pushPath({name: 'CommitView', param: this.item?.full_name})
              }
            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            Row(){
              Text('Issue')
              Blank()
              Text(`${this.item?.open_issues_count}`)
              Blank().width(10)
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .onClick(() => {
              if (this.derivedStack) {
                this.derivedStack.pushPath({name: 'IssueView', param: this.item?.full_name})
              }
            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            Row(){
              Text('Pull Request')
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .onClick(() => {
              if (this.derivedStack) {
                this.derivedStack.pushPath({name: 'PullRequestView', param: this.item?.full_name})
              }
            })
            .width('100%')
            .height(44)
            .padding(15)
            Divider()
            Row(){
              Text('分支')
              Blank()
              Text(this.ref)
                .textAlign(TextAlign.End)
                .maxLines(1)
                .layoutWeight(1)
              Blank().width(10)
              SymbolGlyph($r('sys.symbol.chevron_right'))
            }
            .width('100%')
            .height(44)
            .padding(15)
            .onClick(() => {
              if (this.branch.length == 0) {
                this.getRepoBranch()
              }else{
                this.branchDialog.open()
              }
            })
            Divider()
            Row(){
              Text('README')
              Blank()
              SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            }
            .onClick(() => {
              this.getRepoReadme()
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
          .height('100%')
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

  extractGiteeRepo(url: string): string | null {
    // 正则表达式匹配 https://gitee.com/ 后面跟随的任意字符（非斜杠），直到遇到下一个斜杠，然后是仓库名（任意字符直到字符串结束或遇到问号）
    const pattern = /^https:\/\/gitee\.com\/([^\/]+\/[^\/?]+)/;
    const match = url.match(pattern);
    if (match) {
      // match[1] 包含第一个括号内匹配的内容，即用户名/仓库名
      return match[1];
    }
    return null;
  }

  aboutToAppear(): void {
    mdRegister.HandleHyperlink = (url: string) => {
      console.log('当前Markdown点击URL', url)
      // let ret = this.extractGiteeRepo(url)
      // if (ret == null) {
        this.derivedStack?.pushPath({name: 'WebView', param: url})
      // }else {
      //   this.derivedStack?.pushPath({name: 'RepoView', param: ret})
      // }
    }
    mdRegister.HandleImage = (url: string) => {
      console.log('当前Markdown点击图像', url)
      router.pushUrl({
        url: 'pages/repo/ImagePreviewPage',
        params: [url]
      })
    }
  }

  async getRepo() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}?access_token=${tokenData.getSync('access_token', '')}`
    let response = await efRcpClientApi.get<RepoModel>({
      url: url
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data!
    this.item = result
    this.ref = result.default_branch
  }

  async getRepoReadme() {
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/readme?access_token=${tokenData.getSync('access_token', '')}&ref=${this.ref}`
    let response = await efRcpClientApi.get<ReadmeModel>({
      url: url
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data!
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

    let baseURL = `https://gitee.com/${this.item?.full_name}/raw/${this.ref}/`;
    const regex = /\]\((?!http)(.*?)\)/g; // 注意：在 TypeScript 中正则表达式以 / 开头和结尾
    let replacedContent = retStr.replace(regex, `](${baseURL}$1)`);

    this.content = replacedContent

  }

  async getRepoBranch() {

    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.name}/branches?access_token=${tokenData.getSync('access_token', '')}`
    let response = await efRcpClientApi.get<Array<BranchModel>>({
      url: url
    })
    if (response.error) {
      promptAction.showToast({
        message: response.error.message
      })
      return
    }
    let result = response.data!
    this.branch = result
    this.radioIndex = result.findIndex((item) => (item.name == this.ref))
    this.branchDialog.open()
  }

  // https://gitee.com/api/v5/repos/{owner}/{repo}/branches

  radioIndex = 0

  branchDialog: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: '分支',
      selectedIndex: this.radioIndex,
      confirm: {
        value: '取消',
        action: () => {},
      },
      radioContent: this.generateRadioContent(this.branch.map((item) => (item.name)))
    }),
  })

  generateRadioContent(data: string[]): Array<SheetInfo> {
    return data.map((text, index) => ({
      title: text,
      action: () => {
        if (this.radioIndex != index) {
          this.radioIndex = index;
          this.ref = this.branch[index].name
          this.getRepoReadme()
        }
      }
    } as SheetInfo));
  }
}