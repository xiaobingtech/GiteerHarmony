import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { RepoModel } from '../../model/RepoModel';
import { TreeController, TreeListener, TreeListenerManager, TreeListenType, TreeView, CallbackParam,
  NodeParam  } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoTreeModel } from '../../model/RepoTreeModel';
import call from '@ohos.telephony.call';
import { util } from '@kit.ArkTS';

@Builder
export function RepoTreePageBuilder(name: string, param: Object) {
  RepoTreePage()
}

@Component
export struct RepoTreePage {

  @State item: RepoModel|null = null
  @State isLoading:boolean = true

  derivedStack: DerivedNavPathStack | null = null;

  private treeController: TreeController = new TreeController();
  private treeListener: TreeListener = TreeListenerManager.getInstance().getTreeListener();
  @State clickNodeId: number = 0;

  @State result: Array<RepoTreeModel> = []

  aboutToAppear(): void {
    this.treeListener.on(TreeListenType.NODE_CLICK, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
      console.log('NODE_CLICK')
      if (callbackParam.parentNodeId == undefined) {
        //父节点下得
        let item = this.result[callbackParam.currentNodeId - 1]
        if (item.type == 'dir') {
          this.getContents(item.path, callbackParam.currentNodeId)
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
            
          }else if (suffix == 'mp4') {
            this.derivedStack?.pushPath({name:'VideoView', param: result})
          }
        }
      }else{

      }
    })
    this.treeListener.on(TreeListenType.NODE_ADD, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
      console.log('NODE_ADD')
    })
    this.treeListener.on(TreeListenType.NODE_DELETE, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
      console.log('NODE_DELETE')
    })
    this.treeListener.once(TreeListenType.NODE_MOVE, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
      console.log('NODE_MOVE')
    })
  }

  aboutToDisappear(): void {
    this.treeListener.off(TreeListenType.NODE_CLICK, undefined);
    this.treeListener.off(TreeListenType.NODE_ADD, undefined);
    this.treeListener.off(TreeListenType.NODE_DELETE, undefined);
    this.treeListener.off(TreeListenType.NODE_MOVE, undefined);
  }

  build() {
    NavDestination(){
      Column(){
        if (this.isLoading) {
          LoadingProgress()
            .width(100)
            .height('100%')
        }else{
          TreeView({
            treeController: this.treeController
          })
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
      let nodeParam: NodeParam = { parentNodeId:-1, currentNodeId: 0, isFolder: true, icon: $r('app.media.folder'), selectedIcon: $r('app.media.folder'), primaryTitle: '根目录'}
      this.treeController.addNode(nodeParam)
        .buildDone()
      this.getContents('')
    })
    .title('仓库Tree')
  }

  getContents(path: string, parentNodeId:number = -1, item: RepoTreeModel|null = null) {
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
        for (let i = 0; i < result.length; i++) {
          let item = result[i]
          this.treeController.addNode({parentNodeId: parentNodeId, currentNodeId: i +1, isFolder: item.type == 'dir', icon: item.type == 'dir' ? $r('app.media.folder') : $r('app.media.file'), selectedIcon: item.type == 'dir' ? $r('app.media.folder') : $r('app.media.file'), primaryTitle: item.name})
        }
        if (item == null) {
          this.result = result
        }else{
          item.child = result
        }
        this.treeController.buildDone()
        this.treeController.refreshNode(parentNodeId, '父节点', '子节点')
        this.isLoading = false
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
      this.isLoading = false
    })
  }
}