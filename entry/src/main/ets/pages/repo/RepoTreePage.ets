import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';
import { StarResponse } from '../../model/StarResponse';
import { TreeController, TreeListener, TreeListenerManager, TreeListenType, TreeView, CallbackParam,
  NodeParam  } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { RepoTreeResponse } from '../../model/RepoTreeResponse';

@Builder
export function RepoTreePageBuilder(name: string, param: Object) {
  RepoTreePage()
}

@Component
export struct RepoTreePage {

  @State item: StarResponse = new StarResponse()

  derivedStack: DerivedNavPathStack | null = null;

  private treeController: TreeController = new TreeController();
  private treeListener: TreeListener = TreeListenerManager.getInstance().getTreeListener();
  @State clickNodeId: number = 0;

  aboutToAppear(): void {
    this.treeListener.on(TreeListenType.NODE_CLICK, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
    })
    this.treeListener.on(TreeListenType.NODE_MOVE, (callbackParam: CallbackParam) => {
      this.clickNodeId = callbackParam.currentNodeId;
    })
  }

  aboutToDisappear(): void {
    this.treeListener.off(TreeListenType.NODE_CLICK, undefined);
    this.treeListener.off(TreeListenType.NODE_MOVE, undefined);
  }

  build() {
    NavDestination(){
      Column(){
        TreeView({
          treeController: this.treeController
        })
      }
      .height('100%')
      .width('100%')
    }
    .onReady((context) => {
      this.item = context.pathInfo.param as StarResponse
      this.derivedStack = context.pathStack as DerivedNavPathStack
    })
    .onAppear(() =>{
      let nodeParam: NodeParam = { parentNodeId:-1, currentNodeId: 1, isFolder: true, primaryTitle: '根目录'}
      this.treeController.addNode(nodeParam)
        .buildDone()
      this.getContents('')
    })
    .title(this.item.humman_name)
  }

  getContents(path: string) {
    const session = rcp.createSession()
    // https://gitee.com/api/v5/users/fandongtongxue_admin/starred?access_token=8b54574d49a35d59fcbff25c54d3e934&limit=20&sort=created&direction=desc
    let tokenData = preferences.getPreferencesSync(getContext(this), { name: 'token.db' })
    let url = `https://gitee.com/api/v5/repos/${this.item.full_name}/contents/${path}?access_token=${tokenData.getSync('access_token', '')}`
    console.log('当前URL:',url)
    session.get(url).then((response) => {
      console.info(`Response succeeded: ${response}`);
      let jsonStr = response.toString()
      if (jsonStr != null) {
        let result: Array<RepoTreeResponse> = JSON.parse(jsonStr)
        for (let i = 0; i < result.length; i++) {
          let item = result[i]
          this.treeController.addNode({parentNodeId: -1, currentNodeId: i + 1, isFolder: item.type == 'dir', primaryTitle: item.name})
        }
        this.treeController.buildDone()
        this.treeController.refreshNode(-1, '父节点', '子节点')
      }
    }).catch((err: BusinessError) => {
      console.error(`Response err: Code is ${err.code}, message is ${err.message}`);
    })
  }
}