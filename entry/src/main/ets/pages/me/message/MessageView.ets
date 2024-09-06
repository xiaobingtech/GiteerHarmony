import { AtView } from './AtView'
import { MsgView } from './MsgView'
import { NotificationView } from './NotificationView'

@Builder
export function MessageViewBuilder(name: string, param: Object) {
  MessageView()
}

@Component
struct MessageView{

  build() {
    NavDestination(){
      Tabs(){
        TabContent(){
          MsgView()
        }.tabBar('消息')
        TabContent(){
          NotificationView()
        }.tabBar('通知')
        TabContent(){
          AtView()
        }.tabBar('@我')
      }
    }
    .title('消息通知')
  }
}