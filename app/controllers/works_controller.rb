class WorksController < ApplicationController
  def index
    @albums = Work.where(category: "album").sort
    @books = Work.where(category: "book").sort
    @movies = Work.where(category: "movies").sort
  end
  
  def main
    @spotlight = Work.spotlight
    @top_movies = Work.top_ten "movie"
    @top_books = Work.top_ten "book"
    @top_albums = Work.top_ten "album"
  end

  def show
    @work = Work.find_by(id: params[:id])
  end

  def new
    @work = Work.new
  end

  def create
    work = Work.new(work_params)
    
    if work.save
      flash[:success] = "created #{ work.category } #{ work.id }"
      redirect_to work_path(work.id)
    else
      flash[:action] = "create #{ work.category }"
      flash[:errors] = work.errors
      redirect_to new_work_path
    end
  end

  def destroy
    work = Work.find_by(id: params[:id])
    if work.destroy
      flash[:success] = "destroyed #{ work.category } #{ work.id }"
      redirect_to works_path
    else
      flash[:action] = "delete #{ work.category }"
      flash[:errors] = work.errors
      redirect_to work_path(work.id)
    end
  end

  def edit
    @work = Work.find_by(id: params[:id])
  end

  def update
    work = Work.find_by(id: params[:id])
    
    if work.update(work_params)
      flash[:success] = "edited #{ work.category } #{ work.id }"
      redirect_to work_path(work.id)
    else
      flash[:action] = "edit #{ work.category }"
      flash[:errors] = work.errors
      redirect_to edit_work_path(work.id)
    end
  end

  def upvote
    work = Work.find_by(id: params[:id])
    user = User.find_by(id: session[:user_id])
    
    if user.nil?
      flash[:errors] = { user: ["must be logged in to upvote"] }
      flash[:action] = "upvote"
      redirect_to work_path(work.id)
    elsif user.voted? work
      flash[:errors] = { user: ["already upvoted #{ work.title }"] }
      flash[:action] = "upvote"
      redirect_to work_path(work.id)
    else
      Vote.create(work: work, user: user)
      flash[:success] = "upvoted #{ work.title }"
      redirect_to work_path(work.id)
    end
  end

  private
  def work_params
    params.require(:work).permit(:category, :title, :creator, :published, :description)
  end
end
