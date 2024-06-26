class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers] #認可を行う
  before_action :correct_user, only: [:edit, :update] #たのユーザーの情報をいじれないようにする
  before_action :admin_user, only: :destroy
  def index
    @users = User.where(activated: true).paginate(page: params[:page]) #pagenationを行う,有効なユーザーのみを表示したい。
  end
  def new
    #インスタンスを作成してるのか
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated? #有効でないユーザーには表示しない。
    #debugger
  end

  def create
    @user = User.new(user_params)
    if @user.save 
      #保存が成功した場合
      @user.send_activation_email #メソッドによって有効化メールを送信する
      flash[:info] = "Please check your email to activate your account"
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit 
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    #debugger
    if @user.update(user_params)
      #更新に成功したら
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private #privateいこうがわかりやすいようにあえてインデントを下げている
    def user_params
      #無効なパラメータを追加されないようにする　ストロングパラメータ
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    #正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    #管理者かどうか確認
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end
end
