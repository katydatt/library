class Book < ActiveRecord::Base
belongs_to :category
has_many :comments
has_many :likes

end
