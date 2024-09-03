
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
}

export interface Payload {
  ref: string;
  before: string;
  after: string;
  created: boolean;
  deleted: boolean;
  size: number;
  commits: Commit[];
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