require 'redmine'
require_dependency File.expand_path(File.join(File.dirname(__FILE__), 'app/models/repository_observer'))

Rails.logger.info "register redmine_bitbucketgit_hook"
Redmine::Plugin.register :redmine_bitbucketgit_hook do
  name 'Redmine Bitbucket GIT Hook plugin'
  author 'Bastian Bringenberg'
  description 'This plugin allows your Redmine installation to receive Bitbucket GIT post-receive notifications. Based on bitbucket plugin by Alessio Caiazza and github work by Jakob Skjerning.'
  version '0.0.1'
    settings(:default => {
           :git_dir  => ''
           },
           :partial => 'settings/bitbucketgit_hook_setting')
end

#Rails.configuration.active_record.observers << :repository_observer
ActiveRecord::Base.observers << :repository_observer

Rails.logger.info "redmine_bitbucketgit_hook end"
