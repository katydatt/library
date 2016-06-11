
require 'sinatra'
require 'active_record'
require 'pg'
require 'httparty'

require './db_config'
require './models/book'
require './models/category'
require './models/user'
require './models/comment'
require './models/like'


get '/list' do
  @more = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{params[:book]}")
  books = @more["items"]


  @filtered_books = Array.new

  books.each do |book|
    found = false

    @filtered_books.each do |filtered|
      if book["book_id"] == filtered["book_id"]
        found = true
      end
    end

    if !found
      @filtered_books.push(book)
    end

  end
  erb :list
end

get '/info/:isbn' do

  if book = Book.find_by(isbn: params[:isbn])
    @book_id = book.id
    @book_title = book.title
    @book_author = book.author
    @book_year = book.year
    @book_page_count = book.page_count
    @book_notes = book.notes
    @book_isbn = book.isbn
    @book_category = book.category_id

  else
    @more = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{params[:book]}")
    @infos = @more["items"]

    categories = Category.pluck(:name)
      if @infos.empty?
        redirect to '/search'
      else
        @infos.each do |isbn|

          @book_title = @infos["title"]
          if @infos['authors']
            @book_author = @data['authors'][0]['name']
          else
            @book_author = "No one wrote this"
          end
          @book_notes = @infos['description']
          @book_year = @infos['publishedDate']
          @book_cover = @infos["imageLinks"]["thumbnail"]

          if @data['number_of_pages']
            @book_page_count = @infos['pageCount']
          else
            @book_page_count = "Numb pages not available"
          end

          if @infos['categories']
            @arr = @infos['categories'].map {|s| s['name'].downcase } & categories
            @book_category = @arr.first
          else
            @book_category = "NOT AVAILABLE"
          end

          book = Book.new
          book.title = @book_title
          book.author = @book_author
          book.year = @book_year
          book.cover = @book_cover
          book.page_count = @book_page_count
          book.notes = @book_notes
          book.isbn = params[:isbn]
          book.category_id = @book_category
          book.save
          @book_id = book.id

        end
      end
  end
  @likes = book.likes
  @comments = Comment.find_by(book_id: params[:book_id] )
  erb :info
end








get '/info/:isbn' do

  if book = Book.find_by(isbn: params[:isbn])
      @book_title = book.title
      @book_author = book.author
      @book_year = book.year
      @book_page_count = book.page_count
      @book_category_id = book.category_id
      @book_id = book.id
      @book_isbn = book.isbn
  else

    @infos = HTTParty.get("http://openlibrary.org/api/books?bibkeys=ISBN:#{params[:isbn]}&jscmd=data&format=json")
    @data = @infos["ISBN:#{params[:isbn]}"]

    categories = Category.pluck(:name)
      if @infos.empty?
        redirect to '/search'
      else
        @infos.each do |isbn|

          @book_title = @data["title"]

            if @data['authors']
             @book_author = @data['authors'][0]['name']
            else
             @book_author = "No one wrote this"
            end

              @book_year = @data['publish_date']

            if @data['number_of_pages']
              @book_page_count = @data['number_of_pages']
            else
              @book_page_count = "Numb pages not available"
            end

            if @data['subjects']
              @arr = @data['subjects'].map {|s| s['name'].downcase } & categories
              @category = @arr.first
                if @category == "art-music"
                  category_id = 1
                elsif @category == "biography"
                  category_id = 2
                elsif @category == "business"
                  category_id = 3
                elsif @category == "classics"
                  category_id = 4
                elsif @category == "fiction"
                  category_id = 5
                elsif @category == "history"
                  category_id = 6
                elsif @category == "non-fiction"
                  category_id = 7
                elsif @category == "romance"
                  category_id = 8
                elsif @category == "science"
                  category_id = 9
                end
              @book_category_id = category_id
              else
                @book_category_id = 0
              end

            book = Book.new
            book.title = @book_title
            book.author = @book_author
            book.year = @book_year
            book.page_count = @book_page_count
            book.category_id = @book_category_id
            book.cover = @book_cover
            book.isbn = params[:isbn]
            book.save

            @book_id = book.id
        end
      end
    end
  @comments = book.comments
  @likes = book.likes
  erb :info
end





get '/list' do
  @more = HTTParty.get("http://isbndb.com/api/v2/xml/POV7SEJN/books?q=#{params[:book]}")
  books = @more["isbndb"]["data"]
  # books = HTTParty.get("https://www.googleapis.com/books/v1/volumes?q=#{params[:book]}&fields=items(volumeInfo)")

  @filtered_books = Array.new

  books.each do |book|
    found = false
    @filtered_books.each do |filtered|
      if book["book_id"] == filtered["book_id"]
        found = true
      end
    end

    if !found
      @filtered_books.push(book)
    end

  end
  erb :list
end
