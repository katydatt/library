require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'library'
}

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || options)
