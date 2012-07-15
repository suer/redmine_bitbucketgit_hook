require 'json'
# Update by Bastian Bringenberg <typo3@bastian-bringenberg.de> 2012

class BitbucketgitHookController < ApplicationController

  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    payload = JSON.parse(params[:payload])
    logger.debug { "Received from Bitbucket: #{payload.inspect}" }

    # For now, we assume that the repository name is the same as the project identifier
    identifier = payload['repository']['name']

    #project = Project.find_by_identifier(identifier)
    #raise ActiveRecord::RecordNotFound, "No project found with identifier '#{identifier}'" if project.nil?
    
    searchPath = Dir.getwd + '/' + Setting.plugin_redmine_bitbucketgit_hook[:bitbucketgit_dir].to_s + '/' + payload['repository']['owner'] + '_' + payload['repository']['name'] +'.git'
    logger.info { searchPath }
    repository = Repository.find_by_url(searchPath)
	
	raise TypeError, "Project '#{identifier}' has no repository" if repository.nil?
    raise TypeError, "Repository for project '#{identifier}' is not a Git repository" unless repository.is_a?(Repository::Git)

    # Get updates from the bitbucket repository
    aFile = File.new(repository.url + '/config', "r")
	if aFile
	   content = aFile.sysread(2000)
	   content = /^\surl\s=\s(.*)$/.match( content )
	   logger.info{content[1]}
	else
	   logger.info {"Unable to open file!"}
	end
	
    command = "cd \"#{repository.url}\" && cd .. && rm -rf \"#{repository.url}\" && git clone --bare #{content[1]} \"#{repository.url}\""
    logger.info {command}
    exec(command)

    # Fetch the new changesets into Redmine
    repository.fetch_changesets

    render(:text => 'OK')
  end

  private
  
  def exec(command)
    logger.info { "BitbucketGitHook: Executing command: '#{command}'" }
    output = `#{command}`
    logger.info { "BitbucketGitHook: Shell returned '#{output}'" }
  end

end
