import { EventModel } from '../../model/EventModel';
import { SpanModifier } from '@kit.ArkUI';
import { DerivedNavPathStack } from '../../common/DerivedNavPathStack';

@Component
export struct EventItem {

  private derivedStack: DerivedNavPathStack | null = null

  aboutToAppear(): void {
    this.derivedStack = AppStorage.get('derivedStack') as DerivedNavPathStack
  }

  repoClick: (item: EventModel) => void = () => {

  }

  commitClick: (item: EventModel) => void = () => {

  }

  @Builder
  repoBuilder(){
    Span(this.item.repo.human_name)
    .fontColor(Color.Blue)
    .onClick(() =>{
      this.repoClick(this.item)
    })
  }
  @Builder
  refBuilder(){
    Span(this.item.payload.ref.split('/').pop())
      .fontColor(Color.Blue)
      .onClick(() =>{
        this.repoClick(this.item)
      })
  }

  @Builder
  commitBuilder(){
    Span(this.item.payload.commits[0].sha.substring(0, 7))
      .fontColor(Color.Blue)
      .onClick(() =>{
        this.commitClick(this.item)
      })
  }

  @Prop item: EventModel;
  build() {
    Row({space: 15}){
      Image(this.item?.actor.avatar_url)
        .width(50)
        .borderRadius(25)
      Text(){
        Span(this.item?.actor.name)
        Span(' ')
        if (this.item?.type == 'PushEvent') {
          Span('推送到了')
          Span(' ')
          if (this.item.payload.commits.length > 0) {
            this.repoBuilder()
            Span(' 的')
            this.refBuilder()
            Span(' 分支')
            this.commitBuilder()
            Span(' ')
            Span(this.item.payload.commits[0].message)
          }else{
            this.repoBuilder()
            Span(' 的')
            this.refBuilder()
            Span(' 分支')
          }
        }else if (this.item?.type == 'MemberEvent'){
          Span('加入了仓库 ')
          this.repoBuilder()
        }else if (this.item?.type == 'CreateEvent'){
          Span('创建了仓库 ')
          if (this.item.payload.ref_type == 'branch') {
            this.repoBuilder()
            Span(' 的')
            this.refBuilder()
            Span(' 分支')
          }else{
            this.repoBuilder()
          }
        }else if (this.item?.type == 'IssueCommentEvent'){
          Span('发表了新的任务评论')
        }else if (this.item?.type == 'StarEvent'){
          Span('Star了仓库 ')
          this.repoBuilder()
        }else if (this.item?.type == 'ForkEvent'){
          Span('Fork了仓库 ')
          this.repoBuilder()
        }else if (this.item?.type == 'FollowEvent'){
          Span('关注了 ')
          Span(this.item.payload.target.name)
        }else if (this.item?.type == 'PullRequestEvent'){
          Span(this.item.payload.action)
          Span(' 了PullRequest ')
        }else if (this.item?.type == 'PullRequestCommentEvent'){
          Span('发表了新的Pull Request评论')
        }else if (this.item?.type == 'IssueEvent'){
          Span(' ')
          Span(this.item.payload.action)
          Span(' 了 ')
          Span(this.item.payload.title)
        }
      }
      .width('calc(100% - 70vp)')
    }
    .alignItems(VerticalAlign.Top)
    .padding(15)
  }
}