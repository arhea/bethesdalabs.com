# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, "bethesdalabs"  # EDIT your app name

set :scm, :git
set :repo_url,  'git@github.com:arhea/bethesdalabs.com.git' # EDIT your git repository

set :deploy_to, "/var/www/bethesdalabs.com"
set :deploy_via, :remote_cache

set :use_sudo, false
set :ssh_options, {
    keys: %w(~/.ssh/id_rsa),
   :forward_agent => true
}

namespace :composer do

    desc "Running Composer Self-Update"
    task :update do
        on roles(:all), in: :sequence, wait: 5 do
            execute "composer self-update"
        end
    end

    desc "Running Composer Install"
    task :install do
        on roles(:all), in: :sequence, wait: 5 do
            execute "cd #{release_path} && composer install --no-dev"
        end
    end

end

namespace :laravel do

    desc "Setup Laravel folder permissions"
    task :permissions do
        on roles(:all), in: :sequence, wait: 5 do
            execute "chmod u+x #{release_path}/artisan"
            execute "chmod -R g+w #{release_path}/#{fetch(:release_name)}"
            execute "chmod -R 777 #{release_path}/app/storage/cache"
            execute "chmod -R 777 #{release_path}/app/storage/logs"
            execute "chmod -R 777 #{release_path}/app/storage/meta"
            execute "chmod -R 777 #{release_path}/app/storage/sessions"
            execute "chmod -R 777 #{release_path}/app/storage/views"
        end
    end

    desc "Run Laravel Artisan migrate task."
    task :migrate do
        on roles(:all), in: :sequence, wait: 5 do
            execute "php #{release_path}/artisan migrate"
        end
    end

    desc "Optimize Laravel Class Loader"
    task :optimize do
        on roles(:all), in: :sequence, wait: 5 do
            execute "php #{release_path}/artisan clear-compiled"
            execute "php #{release_path}/artisan optimize"
        end
    end

end

namespace :deploy do

    after :finishing, "composer:update"
    after :finishing, "composer:install"
    after :finishing, "laravel:permissions"
    #after :finishing, "laravel:migrate"
    after :finishing, "laravel:optimize"
    after :finishing, "deploy:cleanup"

end
