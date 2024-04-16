class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    #ユーザーが存在してパスワードが正しければログイン
    if user&.authenticate(params[:session][:password])
      #ユーザーログイン後にユーザー情報のページにリダイレクト
      reset_session #セッション固定攻撃を防ぐためにログイン前にセッションをリセット
      log_in user
      redirect_to user
    else
      #エラーメッセージを作成
      flash.now[:danger] = "Invalid email/password combination"
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
      log_out
      redirect_to root_url, status: :see_other
  end
end
