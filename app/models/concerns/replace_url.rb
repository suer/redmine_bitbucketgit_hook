module ReplaceURL
# CREATE DIR Manually
# KNOWN Problem: Changing BitBucket Git Dir in use
# KNOWN Problem: Two Repositorys with the same name from different users

  extend ActiveSupport::Concern 

  included do
    before_create :replace_url
  end

  def replace_url
    flag = type == 'Git' || self.type == 'Repository::Git'
    flag &= self.url.match('.*(bitbucket.org|github.com).*') 
    if flag 
      base_dir_name = self.url[/[^\/]+.git/]
      url = self.url
      user = /^\S*[:\/](.*)\/\S*$/.match( url )
      user = user[1]
      git_dir = Setting.plugin_redmine_bitbucketgit_hook.with_indifferent_access[:bitbucketgit_dir].to_s
      git_dir = git_dir  + '/' + user + '_' + base_dir_name 
      redminedir = Dir.getwd + '/'
      comm_str = ""
      unless Dir[redminedir+git_dir] == []
        comm_str = 'rm -rf "' + redminedir + git_dir + '" &&'
      end
      comm_str += 'git clone --mirror '+ url + ' "'+ redminedir + git_dir +'"'
      b = system(comm_str)
      self.url = redminedir + git_dir
      return false
    end
  end
  
  private
  def exec(command)
    Rails.logger.info("BitbucketGitHook: Executing command: '#{command}'")
    output = `#{command}`
    Rails.logger.info("BitbucketGitHook: Shell returned '#{output}'")
  end
 
end
