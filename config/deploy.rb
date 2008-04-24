set :application, "redmine"
set :user, "deployer"


set :repository,  "ssh://bcampos.fireho.com:22223/var/repo/redmine.git"
#set :repository,  "ssh://deploy_d...@mydomain.com:8888/opt/repos/project.git "
set :scm, :git
#ssh_options[:paranoid] = false
ssh_options[:port] = 22223
# git user and pass 
default_run_options[:pty] = true
#set :scm_passphrase, 

#set :branch, "fireho"
set :branch, "fireho/master"
set :deploy_via, :remote_cache


#set :git_shallow_clone, 1
#Shallow cloning will do a clone each time, but will only get the first tree, 
#not all the parents trees, too. This makes it a bit closer to how an 
#svn checkout works, but be careful when using with the set :branch option, 
#because it wont work unless the shallow clone number is big enough
# to encompass the branch you’ve specified.

#set :git_enable_submodules, 1

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/www/apps/#{application}"
#s#et :domain, "redmine.fireho.com"
set :use_sudo, false

role :app, "bcampos.fireho.com"
role :web, "bcampos.fireho.com"
role :db,  "bcampos.fireho.com", :primary => true


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