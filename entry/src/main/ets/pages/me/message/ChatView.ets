import { Chat, ChatRole, ChatMessage } from '@changwei/chatui'

@Component
struct ChatView {
  build() {
    NavDestination(){
      Row() {
        Column() {
          Chat({
            title:'TA',
            welcomeMessage: '文明发言，真诚提问',
            onSendMessage: (ctl, message) => {
              //发送用户消息
              ctl.postMessage(message)
            }
          })
        }
      }
      .height('100%')
    }
  }
}