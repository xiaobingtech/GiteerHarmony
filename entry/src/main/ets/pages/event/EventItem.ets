import { EventModel } from '../../model/EventModel';
import { SpanModifier } from '@kit.ArkUI';

@Component
export struct EventItem {
  @Prop item: EventModel|null = null;
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
            Span(this.item.repo.full_name)
            Span(' 的')
            Span(this.item.payload.ref)
            Span(' 分支')
            Span(this.item.payload.commits[0].sha.substring(0, 7))
            Span(' ')
            Span(this.item.payload.commits[0].message)
          }else{
            Span(this.item.repo.full_name)
            Span(' 的')
            Span(this.item.payload.ref)
            Span(' 分支')
          }
        }else if (this.item?.type == 'MemberEvent'){
          Span('加入了仓库 ')
          Span(this.item.repo.full_name)
        }else if (this.item?.type == 'CreateEvent'){
          Span('创建了仓库 ')
          if (this.item.payload.ref_type == 'branch') {
            Span(this.item.repo.full_name)
            Span(' 的')
            Span(this.item.payload.ref)
            Span(' 分支')
          }else{
            Span(this.item.repo.full_name)
          }
        }else if (this.item?.type == 'IssueCommentEvent'){
          Span('发表了新的任务评论')
        }else if (this.item?.type == 'StarEvent'){
          Span('Star了仓库 ')
          Span(this.item.repo.full_name)
        }else if (this.item?.type == 'ForkEvent'){
          Span('Fork了仓库 ')
          Span(this.item.repo.full_name)
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