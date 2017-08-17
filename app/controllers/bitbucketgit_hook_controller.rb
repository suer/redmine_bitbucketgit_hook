require 'json'
# Update by Bastian Bringenberg <typo3@bastian-bringenberg.de> 2012

class BitbucketgitHookController < ApplicationController

  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    payload = (params[:payload] ? JSON.parse(params[:payload]) : JSON.parse(request.body.read, {:symbolize_names => false}))

    repo = bitbucker_repository(payload)
    
    searchPath = Dir.getwd + '/' + Setting.plugin_redmine_bitbucketgit_hook[:bitbucketgit_dir].to_s + '/' + repo.owner + '_' + repo.slug + '.git'

    repository = Repository.find_by_url(searchPath)

    raise TypeError, "Project '#{repo.identifier}' has no repository" if repository.nil?
    raise TypeError, "Repository for project '#{repo.identifier}' is not a Git repository" unless repository.is_a?(Repository::Git)

    repos = ''
    if repo.is_private
        repos = "git@bitbucket.org:#{repo.owner}/#{repo.slug}.git"
    else
        repos = "https://bitbucket.org/#{repo.owner}/#{repo.slug}.git"
    end
    #command = "cd \"#{repository.url}\" && cd .. && rm -rf \"#{repository.url}\" && git clone --bare #{repos} \"#{repository.url}\""
    bFile = File.new(repository.url, "r")
    if bFile
        Rails.logger.info {"File exists"}
        command = "cd \"#{repository.url}\" && #{Repository::Git.scm_command} fetch"
    else
        command = "cd \"#{repository.url}\" && #{Repository::Git.scm_command} clone --mirror #{repos} \"#{repositry.url}\""
    end

    Rails.logger.info {command}
    exec(command)

    # Fetch the new changesets into Redmine
    repository.fetch_changesets

    render(:text => 'OK')
  end

  private

  def bitbucker_repository(payload)
    repository = Struct.new(:identifier, :owner, :slug, :is_private)

    identifier = payload['repository']['name']
    owner = (payload['repository']['owner'].is_a?(Hash) ? payload['repository']['owner']['username'] : payload['repository']['owner'])
    slug = payload['repository']['slug'] || identifier
    is_private = payload['repository']['is_private']

    repository.new(identifier, owner, slug, is_private)
  end
  
  def exec(command)
    logger.info { "BitbucketGitHook: Executing command: '#{command}'" }
    output = `#{command}`
    logger.info { "BitbucketGitHook: Shell returned '#{output}'" }
  end

end
