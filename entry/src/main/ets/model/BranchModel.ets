export interface Author {
  name: string;
  date: string;
  email: string;
}

export interface Committer {
  name: string;
  date: string;
  email: string;
}

export interface Commit {
  author: Author;
  committer: Committer;
  message: string;
}

export interface BranchModel {
  name: string;
  commit: Commit;
  protected: boolean;
  protection_url: string;
}