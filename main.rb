
require 'sinatra'
require 'active_record'
require 'pg'
require 'httparty'
require 'googlebooks'
require './db_config'
require './models/book'
require './models/category'
require './models/user'
require './models/comment'
require './models/like'

enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end

end

get '/' do
  erb :index
end

get '/user/signup' do
  erb :signup
end

post '/user/signup' do
    #saving my user on db
  user = User.new
  user.email = params[:email]
  user.first_name = params[:first_name]
  user.last_name = params[:last_name]
  user.date_of_birth = params[:date_of_birth]
  user.address = params[:address]
  user.city = params[:city]
  user.password = params[:password]
  user.save

  if user.save
    redirect to '/'
  else
    "Sorry, something went wrong. Please try again"
  end

  erb :signup
end

get '/session/login' do

  erb :login
end

post '/session' do

  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/search'
  else
    "Sorry, try again"
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect to '/'
end

delete '/user/:id' do
  user = User.find(params[:id])
  user.destroy
  redirect to '/'
end

get '/account/:id' do
  @user = current_user
  @comments = Comment.all
  erb :user_profile
end

patch '/account/:id' do
  user = User.find_by(id: params[:id])
  user.first_name = params[:first_name]
  user.last_name = params[:last_name]
  user.email = params[:email]
  user.password = params[:password]
  user.city = params[:city]
  user.address = params[:address]
  user.date_of_birth = params[:date_of_birth]
  user.save
  redirect to "/account/#{ params[:id] }"

end

get '/account/:id/edit' do
  @user = User.find_by(id: params[:id])
  erb :edit_user
end

get '/search' do
  @categories = Category.all
  erb :search
end

get '/category/:id' do
  @books = Category.find(params[:id]).books
  erb :category
end


get '/list' do
  @books = GoogleBooks.search(params[:title])

  erb :list
end

get '/info/:isbn' do
    if book = Book.find_by(isbn: params[:isbn])
      @book_title = book.title
      @book_author = book.author
      @book_year = book.year
      @book_cover = book.cover
      @book_page_count = book.page_count
      @book_id = book.id
      @book_isbn = book.isbn
      @book_type = book.department
      @book_category_id = book.category_id
    else
      @texts = GoogleBooks.search(params[:isbn])
        @texts.each do |text|
          @book_title = text.title
          @book_author = text.authors
          @book_year = text.published_date
          @book_cover = text.image_link(:zoom => 2)
          @book_page_count = text.page_count
          @book_notes = text.description
          @book_type = text.categories
          @book_isbn = text.isbn
        end

      book = Book.new
      book.title = @book_title
      book.author = @book_author
      book.year = @book_year
      book.cover = @book_cover
      book.page_count = @book_page_count
      book.notes = @book_notes
      book.isbn = params[:isbn]
      book.department = @book_type
        if @book_type == "Arts & Disciplines"
          book.category_id = 1
        elsif @book_type == "Biography & Autobiography"
          book.category_id = 2
        elsif @book_type == "Business & Economics"
          book.category_id = 3
        elsif @book_type == "Juvenile Fiction"
          book.category_id = 4
        elsif @book_type == "Fiction"
          book.category_id = 5
        elsif @book_type == "History"
          book.category_id = 6
        elsif @book_type == "Nonfiction"
          book.category_id = 7
        elsif @book_type == "Drama"
          book.category_id = 8
        elsif @book_type == "Technology & Engineering"
          book.category_id = 9
        else
          book.category_id = 5
        end

      book.save
      @book_id = book.id

    end

    @comments = book.comments
    @likes = book.likes

  erb :info
end


get '/info/:isbn/edit' do
  @book = Book.find_by(isbn: params[:isbn])
  erb :edit
end

patch '/info/:isbn' do
  book = Book.find_by(isbn: params[:isbn])
  book.title = params[:title]
  book.page_count = params[:number_pages]
  book.category_id = params[:category_id ]
  book.notes = params[:notes]
  book.cover = params[:cover]
  book.save
  redirect to "/info/#{ params[:isbn] }"
end

post '/info/:isbn' do
  comment = Comment.new
  comment.body = params[:body]
  comment.book_id = params[:book_id]
  comment.user_id = params[:user_id]
  comment.save
  redirect to "/info/#{ comment.book.isbn }"
end

delete '/info/:isbn' do
  comment = Comment.find_by(params[:user_id])
  comment.delete
  redirect to "/info/#{ params[:isbn] }"
end

post '/like/:isbn' do
  like = Like.new
  like.book_id = params[:book_id]
  like.user_id = current_user.id
  like.save
  redirect to "/info/#{ like.book.isbn }"
end
