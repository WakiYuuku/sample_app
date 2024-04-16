module SessionsHelper
    #渡されたユーザでログインする,セッションに暗号化されたユーザIDを渡す
    def log_in(user)
        session[:user_id] = user.id
    end

    #現在ログイン中のユーザーを返す
    def current_user
        #セッションにユーザーIDが存在すれば
        if session[:user_id]
            @current_user ||= User.find_by(id: session[:user_id])
        end
    end

    #ユーザーがログインしていればTrue、その他ならFalse
    def logged_in?
        !current_user.nil?
    end

    def log_out
        reset_session
        @current_user = nil #安全のため
    end
end
