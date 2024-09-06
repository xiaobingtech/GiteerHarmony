export interface Sender {
  id: number;
  login: string;
  name: string;
  avatar_url: string;
  url: string;
  html_url: string;
  remark: string;
  followers_url: string;
  following_url: string;
  gists_url: string;
  starred_url: string;
  subscriptions_url: string;
  organizations_url: string;
  repos_url: string;
  events_url: string;
  received_events_url: string;
  type: string;
}

export interface MsgModelList {
  id: number;
  sender: Sender;
  unread: boolean;
  content: string;
  updated_at: string;
  url: string;
  html_url: string;
}

export interface MsgModel {
  total_count: number;
  list: MsgModelList[];
}