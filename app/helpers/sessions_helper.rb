module SessionsHelper
    #渡されたユーザでログインする,セッションに暗号化されたユーザIDを渡す
    def log_in(user)
        session[:user_id] = user.id
        #セッションリプレイ攻撃から保護する
        session[:session_token] = user.session_token
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する
    def remember(user)
        user.remember #記憶トークンをデータベースに保存
        cookies.permanent.encrypted[:user_id] = user.id #IDを有効期限と暗号化を行いクッキーに保存
        cookies.permanent[:remember_token] = user.remember_token #記憶トークンもクッキーに保存
    end

    #記憶トークンcookieに対応するユーザーを返す
    def current_user
        #セッションにユーザーIDが存在すれば
        if (user_id = session[:user_id])
            user = User.find_by(id: user_id)
            if user && session[:session_token] == user.session_token
                @current_user = user
            end

        elsif (user_id = cookies.encrypted[:user_id]) #クッキーにuser_idがあって復号化できた場合
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    #ユーザーがログインしていればTrue、その他ならFalse
    def logged_in?
        !current_user.nil?
    end

    #現在のセッションを破棄する
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    #現在のユーザーをログアウトする
    def log_out
        forget(current_user)
        reset_session
        @current_user = nil #安全のため
    end
end
