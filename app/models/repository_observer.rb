class RepositoryObserver < ActiveRecord::Observer
# ONLY SSH OR Public RightNow
# CREATE DIR Manually
# SSH Key has to be known
# KNOWN Problem: Changing BitBucket Git Dir in use
# KNOWN Problem: Two Repositorys with the same name from different users

  def before_save(repository)
      if repository.type == 'Git' && repository.url.match('.*bitbucket.org.*')
          base_dir_name = repository.url[/[\/][^\/]+.git/]
          url = repository.url
          git_dir = Setting.plugin_redmine_bitbucketgit_hook[:bitbucketgit_dir].to_s
          git_dir = git_dir + base_dir_name 
          redminedir = Dir.getwd + '/'
          if Dir[redminedir+git_dir] == []
          	exec('git clone --bare '+ url + ' "'+ redminedir + git_dir +'"')
        	repository.url = redminedir + git_dir
          else
          	p "Dir already in use..."
          	return false
          end
      end
  end
  
  private
  def exec(command)
    p "BitbucketGitHook: Executing command: '#{command}'"
    output = `#{command}`
    p "BitbucketGitHook: Shell returned '#{output}'"
  end

end