

export interface Tree {
  sha: string;
  url: string;
}

export interface Commit {
  author: Author;
  committer: Committer;
  message: string;
  tree: Tree;
}

export interface Author {
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
  date: string;
  email: string;
}

export interface Committer {
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
  date: string;
  email: string;
}

export interface Parent {
  sha: string;
  url: string;
}

export interface CommitModel {
  url: string;
  sha: string;
  html_url: string;
  comments_url: string;
  commit: Commit;
  author: Author;
  committer: Committer;
  parents: Parent[];
}