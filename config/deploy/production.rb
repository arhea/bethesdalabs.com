set :stage, "production"

server 'bethesdalabs.com', user: 'root', roles: %w{web app db}
