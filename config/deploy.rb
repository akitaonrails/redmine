# APP
# #
set :application, "redmine"
set :user, "nofxxx"

# REPO
# #
set :repository,  "git://github.com/nofxx/redmine.git"
set :scm, :git
#set :scm_passphrase, 
#set :branch, "fireho/master"
set :branch, "master"
set :deploy_via, :remote_cache
#set :git_enable_submodules, 1
#set :git_shallow_clone, 1
#nao eh bom com set :branch

# SSH
# #
ssh_options[:paranoid] = false
ssh_options[:port] = 22223
default_run_options[:pty] = true
# git user and pass 

# OPTIONS
# #
set :deploy_to, "/var/www/apps/#{application}"
#s#et :domain, "redmine.fireho.com"
set :use_sudo, false

# ROLES
# #
#if ENV['staging']
  set :domain, "ssaint.fireho.com"
  
#else
#  set :domain, application
#end

role :app, domain
role :web, domain
role :db,  domain, :primary => true

# TASKS
# #
desc "Create symlinks for shared upload directories" 
task :after_symlink do 
      run "rm -rf #{release_path}/files"
      run "ln -nfs #{shared_path}/files #{release_path}/files" 
end

# PASSENGER DEPLOY
# #
namespace :deploy do  
  task :start, :roles => :app do  
  end  
  
  task :stop, :roles => :app do  
  end  
  
  task :restart, :roles => :app do  
    run "touch #{release_path}/tmp/restart.txt"  
  end  
  
  task :after_update_code, :roles => :app do  
    run "rm -rf #{release_path}/public/.htaccess"  
  end  
end