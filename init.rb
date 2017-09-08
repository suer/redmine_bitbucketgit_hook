require 'redmine'
require_dependency File.expand_path(File.join(File.dirname(__FILE__), 'app/models/concerns/replace_url'))

Repository.class_eval do
  include ReplaceURL
end

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
