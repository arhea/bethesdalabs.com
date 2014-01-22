set :stage, :production

set :deploy_to, "/var/www"

server "bethesdalabs.com", user: "root", roles: %w{web app db}
