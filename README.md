= Life-line.me


== Starting Setup

 cp config/database.template.yml config/database.yml
 sudo rake:gems:install
 rake db:create:all
 rake db:schema:load