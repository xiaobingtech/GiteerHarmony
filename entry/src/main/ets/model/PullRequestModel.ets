export interface Assignee {
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
  assignee: boolean;
  code_owner: boolean;
  accept: boolean;
}

export interface Tester {
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
  assignee: boolean;
  code_owner: boolean;
  accept: boolean;
}

export interface Self {
  href: string;
}

export interface Html {
  href: string;
}

export interface Issue {
  href: string;
}

export interface Comment {
  href: string;
}

export interface Review_comment {
  href: string;
}
export interface Commit {
  href: string;
}

export interface _link {
  self: Self;
  html: Html;
  issue: Issue;
  comments: Comment;
  review_comments: Review_comment;
  review_comment: Review_comment;
  commits: Commit;
}


export interface User {
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


export interface Repo {
  id: number;
  full_name: string;
  human_name: string;
  url: string;
  namespace: Namespace;
  path: string;
  name: string;
  owner: Owner;
  assigner: Assigner;
  description: string;
  private: boolean;
  public: boolean;
  internal: boolean;
  fork: boolean;
  html_url: string;
  ssh_url: string;
}

export interface Head {
  label: string;
  ref: string;
  sha: string;
  user: User;
  repo: Repo;
}
export interface Namespace {
  id: number;
  type: string;
  name: string;
  path: string;
  html_url: string;
}

export interface Owner {
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

export interface Assigner {
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

export interface Base {
  label: string;
  ref: string;
  sha: string;
  user: User;
  repo: Repo;
}

export interface PullRequestModel {
  id: number;
  url: string;
  html_url: string;
  diff_url: string;
  patch_url: string;
  issue_url: string;
  commits_url: string;
  review_comments_url: string;
  review_comment_url: string;
  comments_url: string;
  number: number;
  close_related_issue: number;
  prune_branch: boolean;
  state: string;
  assignees_number: number;
  testers_number: number;
  assignees: Assignee[];
  testers: Tester[];
  milestone: string;
  labels: string[];
  locked: boolean;
  created_at: string;
  updated_at: string;
  closed_at: string;
  draft: boolean;
  merged_at: string;
  mergeable: boolean;
  can_merge_check: boolean;
  _links: _link;
  user: User;
  ref_pull_requests: string[];
  title: string;
  body: string;
  head: Head;
  base: Base;
}