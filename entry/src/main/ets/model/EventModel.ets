
export interface Actor {
  id: number;
  login: string;
  name: string;
  avatar_url: string;
  url: string;
  html_url: string;
  remark: string;
}

export interface Namespace {
  id: number;
  type: string;
  name: string;
  path: string;
  html_url: string;
}

export interface Repo {
  id: number;
  full_name: string;
  human_name: string;
  url: string;
  namespace: Namespace;
}

export interface Org {
  id: number;
  login: string;
  name: string;
  url: string;
  avatar_url: string;
}

export interface Author {
  email: string;
  name: string;
}

export interface Commit {
  sha: string;
  author: Author;
  message: string;
  url: string;
  html_url: string;
}


export interface Payload {
  ref: string;
  ref_type: string;
  action: string;
  target: Target
  title: string;
  before: string;
  after: string;
  created: boolean;
  deleted: boolean;
  size: number;
  commits: Commit[];
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
  number: string;
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
  body: string;
  head: Head;
  base: Base;
  issue: Issue;
  comment: Comment
  pull_request: Pull_request
}

export interface Pull_request {
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
  closed_at?: string;
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
  id: number;
  url: string;
  repository_url: string;
  labels_url: string;
  comments_url: string;
  html_url: string;
  parent_url?: string;
  number: string;
  parent_id: number;
  depth: number;
  state: string;
  title: string;
  body: string;
  user: User;
  labels: string[];
  assignee?: string;
  collaborators: string[];
  repository: Repo;
  milestone: string;
  created_at: string;
  updated_at: string;
  plan_started_at?: string;
  deadline: string;
  finished_at?: string;
  scheduled_time: number;
  comments: number;
  priority: number;
  issue_type: string;
  program: string;
  security_hole: boolean;
  issue_state: string;
  branch: string;
  issue_type_detail: Issue_type_detail;
  issue_state_detail: Issue_state_detail;
}

export interface Issue_type_detail {
  id: number;
  title: string;
  template: string;
  ident: string;
  color: string;
  is_system: boolean;
  created_at: string;
  updated_at: string;
}

export interface Issue_state_detail {
  id: number;
  title: string;
  color: string;
  icon: string;
  command: string;
  serial: number;
  created_at: string;
  updated_at: string;
}

export interface Comment {
  href: string;
  url: string;
  html_url: string;
  issue_url: string;
  id: number;
  user: User;
  created_at: string;
  updated_at: string;
  body: string;
}

export interface Review_comment {
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

export interface Head {
  label: string;
  ref: string;
  sha: string;
  user: User;
  repo: Repo;
}

export interface Base {
  label: string;
  ref: string;
  sha: string;
  user: User;
  repo: Repo;
}

export interface Target {
  name: string
}

export interface EventModel {
  id: number;
  type: string;
  actor: Actor;
  repo: Repo;
  org: Org;
  public: boolean;
  created_at: string;
  payload: Payload;
}