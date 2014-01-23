# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, "bethesdalabs"  # EDIT your app name

set :default_stage, "production"

set :scm, :git
set :repo_url,  'git@github.com:arhea/bethesdalabs.com.git' # EDIT your git repository

set :use_sudo, false
set :ssh_options, {
    keys: %w(~/.ssh/id_rsa),
   :forward_agent => true
}

namespace :deploy do

    desc "Installing PHP dependencies."
    task :composer_install do
        on roles(:all), in: :sequence, wait: 5 do
            execute "composer self-update"
            execute "cd #{release_path} && composer install --no-dev"
        end
    end

    desc "Setup Laravel permissions and optimize class loader."
    task :laravel_setup do
        on roles(:all), in: :sequence, wait: 5 do
            execute "chmod u+x #{release_path}/artisan"
            execute "chmod -R g+w #{release_path}/#{fetch(:release_name)}"
            execute "chmod -R 777 #{release_path}/app/storage/cache"
            execute "chmod -R 777 #{release_path}/app/storage/logs"
            execute "chmod -R 777 #{release_path}/app/storage/meta"
            execute "chmod -R 777 #{release_path}/app/storage/sessions"
            execute "chmod -R 777 #{release_path}/app/storage/views"
            execute "php #{release_path}/artisan clear-compiled"
            execute "php #{release_path}/artisan optimize"
        end
    end

    desc "Run Laravel Artisan migrate task."
    task :migrate do
        on roles(:all), in: :sequence, wait: 5 do
            execute "php #{release_path}/artisan migrate"
        end
    end

    task :uptime do
        on roles(:all) do |host|
            info "Host #{host} (#{host.roles.to_a.join(', ')}):\t#{capture(:uptime)}"
        end
    end

    after :finishing, "composer_install"
    after :finishing, "laravel_setup"
    after :finishing, "deploy:cleanup"

end
