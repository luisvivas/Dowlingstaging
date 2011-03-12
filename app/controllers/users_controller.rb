class UsersController < ApplicationController
  respond_to :html
  skip_filter :check_user_profile
  before_filter :authenticate_user!

  def index
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def new
    @user = User.new
    respond_with(@user)
  end

  def edit
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def create
    @user = User.new(params[:user])
    flash[:notice] = 'User was successfully created.' if @user.save
    respond_with(@user)
  end

  def update
    @user = User.find(params[:id])
    flash[:notice] = 'User was successfully updated.' if @user.update_attributes(params[:user])
    respond_with(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_with(@user)
  end
end
