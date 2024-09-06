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
}

export interface Repository {
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
  forks_url: string;
  keys_url: string;
  collaborators_url: string;
  hooks_url: string;
  branches_url: string;
  tags_url: string;
  blobs_url: string;
  stargazers_url: string;
  contributors_url: string;
  commits_url: string;
  comments_url: string;
  issue_comment_url: string;
  issues_url: string;
  pulls_url: string;
  milestones_url: string;
  notifications_url: string;
  labels_url: string;
  releases_url: string;
  recommend: boolean;
  gvp: boolean;
  homepage: string;
  language: string;
  forks_count: number;
  stargazers_count: number;
  watchers_count: number;
  default_branch: string;
  open_issues_count: number;
  has_issues: boolean;
  has_wiki: boolean;
  issue_comment: boolean;
  can_comment: boolean;
  pull_requests_enabled: boolean;
  has_page: boolean;
  license?: string;
  outsourced: boolean;
  project_creator: string;
  members: string[];
  pushed_at: string;
  created_at: string;
  updated_at: string;
  parent: string;
  paas: string;
  assignees_number: number;
  testers_number: number;
  assignee: Assignee[];
  testers: Tester[];
  status: string;
  programs: string[];
  enterprise: string;
  project_labels: string[];
  issue_template_source: string;
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

export interface IssueModel {
  id: number;
  url: string;
  repository_url: string;
  labels_url: string;
  comments_url: string;
  html_url: string;
  parent_url: string;
  number: string;
  parent_id: number;
  depth: number;
  state: string;
  title: string;
  body: string;
  user: User;
  labels: string[];
  assignee: string;
  collaborators: string[];
  repository: Repository;
  milestone: string;
  created_at: string;
  updated_at: string;
  plan_started_at: string;
  deadline: string;
  finished_at: string;
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