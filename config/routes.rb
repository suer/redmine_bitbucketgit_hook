ActionController::Routing::Routes.draw do |map|
 map.connect 'bitbucketgit_hook', :controller => 'bitbucketgit_hook', :action => 'index'#,
 # :conditions => {:method => :post}
end
