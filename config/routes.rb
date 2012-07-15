RedmineApp::Application.routes.draw do
 match 'bitbucketgit_hook', :controller => 'bitbucketgit_hook', :action => 'index'#,
 # :conditions => {:method => :post}
end
