require "bundler/capistrano"
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"

server "staging.startupo.cc", :web, :app, :db, primary: true

set :rvm_ruby_string, '1.9.3-p125'

set :application, "deploy"
set :user, "staging"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :rvm_type, :system

set :scm, "git"
set :repository, "git@github.com:gogojimmy/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :custom_setup, :roles => [:app] do
    run "cp #{shared_path}/config/*.yml #{release_path}/config/"
  end
end

task :tail_log, :roles => :app do
  run "tail -f #{shared_path}/log/#{rails_env}.log"
end

before "deploy:assets:precompile", "deploy:custom_setup"

after "deploy", "deploy:cleanup"

after "deploy:migrations", "deploy:cleanup"
