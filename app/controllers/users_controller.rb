class UsersController < ApplicationController
  def new
    #インスタンスを作成してるのか
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
    #debugger
  end

  def create
    @user = User.new(user_params)
    if @user.save 
      #保存が成功した場合
      #ログインも一緒に行う
      reset_session
      log_in @user
      flash[:success] = "Wlecom to the Sample App!"
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private #privateいこうがわかりやすいようにあえてインデントを下げている
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
