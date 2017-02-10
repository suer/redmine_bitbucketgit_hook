RedmineApp::Application.routes.draw do
  match 'bitbucketgit_hook', :controller => 'bitbucketgit_hook', :action => 'index', via: [:get, :post]
end
