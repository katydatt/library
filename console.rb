require 'pry'
require 'active_record'

ActiveRecord::Base.logger = Logger.new(STDERR)

require './db_config'
require './models/book'
require './models/category'
require './models/user'
require './models/comment'
require '.models/like'



binding.pry
