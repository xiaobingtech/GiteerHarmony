export interface Link {
  self: string;
  html: string;
}

export interface RepoTreeModel {
  type: string;
  size: string;
  name: string;
  path: string;
  sha: string;
  url: string;
  html_url: string;
  download_url: string;
  _links: Link;
  child: Array<RepoTreeModel>;
}