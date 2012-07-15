class RepositoryObserver < ActiveRecord::Observer
# CREATE DIR Manually
# KNOWN Problem: Changing BitBucket Git Dir in use
# KNOWN Problem: Two Repositorys with the same name from different users

  def before_save(repository)
      Rails.logger.info("before save")
      if repository.type == 'Repository::Git' && repository.url.match('.*bitbucket.org.*')
          base_dir_name = repository.url[/[^\/]+.git/]
          url = repository.url
          user = /^\S*[:\/](.*)\/\S*$/.match( url )
          user = user[1]
          git_dir = Setting.plugin_redmine_bitbucketgit_hook[:bitbucketgit_dir].to_s
          git_dir = git_dir  + '/' + user + '_' + base_dir_name 
          Rails.logger.info git_dir
          redminedir = Dir.getwd + '/'
          Rails.logger.info redminedir+git_dir
          if Dir[redminedir+git_dir] == []
                comm_str = 'git clone --bare '+ url + ' "'+ redminedir + git_dir +'"'
                b = system(comm_str)
        	repository.url = redminedir + git_dir
                return false
          else
          	Rails.logger.info "Dir already in use..."
          	return false
          end
      end
  end
  
  private
  def exec(command)
    Rails.logger.info("BitbucketGitHook: Executing command: '#{command}'")
    output = `#{command}`
    Rails.logger.info("BitbucketGitHook: Shell returned '#{output}'")
  end

end
