require 'json'
# Update by Bastian Bringenberg <typo3@bastian-bringenberg.de> 2012

class BitbucketgitHookController < ApplicationController

  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    payload = JSON.parse(params[:payload])
    Rails.logger.info "Received from Bitbucket: #{payload.inspect}"

    # For now, we assume that the repository name is the same as the project identifier
    identifier = payload['repository']['name']
    owner = payload['repository']['owner']
    slug = payload['repository']['slug']
    is_private = payload['repository']['is_private']
    #project = Project.find_by_identifier(identifier)
    #raise ActiveRecord::RecordNotFound, "No project found with identifier '#{identifier}'" if project.nil?
    
    searchPath = Dir.getwd + '/' + Setting.plugin_redmine_bitbucketgit_hook[:bitbucketgit_dir].to_s + '/' + owner + '_' + slug +'.git'
    Rails.logger.info searchPath
    repository = Repository.find_by_url(searchPath)
	
	raise TypeError, "Project '#{identifier}' has no repository" if repository.nil?
    raise TypeError, "Repository for project '#{identifier}' is not a Git repository" unless repository.is_a?(Repository::Git)

    repos = ''
    if is_private
        repos = "git@bitbucket.org:#{owner}/#{slug}.git"
    else
        repos = "https://bitbucket.org/#{owner}/#{slug}.git"
    end
    #command = "cd \"#{repository.url}\" && cd .. && rm -rf \"#{repository.url}\" && git clone --bare #{repos} \"#{repository.url}\""
    bFile = File.new(repository.url, "r")
    if bFile
        Rails.logger.info {"File exists"}
        command = "cd \"#{repository.url}\" && git fetch"
    else
        command = "cd \"#{repository.url}\" && git clone --mirror #{repos} \"#{repositry.url}\""
    end

    Rails.logger.info {command}
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
