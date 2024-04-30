



require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest #Testで終わらないクラスは明示的に実行しない限り実行されない
  def setup
    @user = users(:michael) #fixtureからログイン可能なユーザー情報を取得
  end
end

class InvalidPasswordTest < UsersLogin

  test "login path" do
    get login_path #ログインページにアクセス
    assert_template 'sessions/new'#正しいテンプレートが読み込まれいるか
  end

  test "login with valid email/invalid password" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } } #無効
    assert_not is_logged_in? #ログインできていないことを確認
    assert_template 'sessions/new' #正しいテンプレート？
    assert_not flash.empty? #フラッシュが表示されているか
    get root_path #Homeに戻る
    assert flash.empty? #フラッシュが消えていることを確認
  end
end

class ValidLogin < UsersLogin
  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } } #有効なログイン
  end
end

class ValidLoginTest < ValidLogin

  test "valid login" do
    assert is_logged_in? #ログインできているか？
    assert_redirected_to @user #プロフィール画面に遷移先を指定
  end

  test "redirect after login" do
    follow_redirect! #リダイレクト
    assert_template 'users/show' #正しいページが表示されているか
    assert_select "a[href=?]", login_path, count: 0 #ログインしているため表示しない
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path #ログアウト
  end
end

class LogoutTest < Logout
  test "successful logout" do
    assert_not is_logged_in? #ログアウトできているか
    assert_response :see_other #ステータスコードの確認
    assert_redirected_to root_url
  end

  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "should still work after logout in second window" do
    delete logout_path
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    #assert_not cookies[:remember_token].blank? #nilもfalseとして返す 
    assert_equal cookies[:remember_token], assigns(:user).remember_token
  end

  test "login without remembering" do
    #cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    #cookieが削除されているか検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end

# require "test_helper"

# class UsersLoginTest < ActionDispatch::IntegrationTest
#   def setup
#     @user = users(:michael)
#   end
#   test "login with valid email/ invalid password" do
#     get login_path
#     assert_template 'sessions/new'
#     #わざと無効なparamハッシュを使ってセッションパスにPOSTする
#     post login_path params: { session: {email: @user.email,
#                                       password: "invalid"}}
#     #ログインができていないことを確認する
#     assert_not is_logged_in?
#     #正しいステータスを返すかチェック
#     assert_response :unprocessable_entity
#     #正しいテンプレートを表示するかチェック
#     assert_template 'sessions/new'
#     #フラッシュメッセージが表示されているか
#     assert_not flash.empty?
#     #別のページに移動する
#     get root_path
#     #別のページでフラッシュが表示されていないことを確認
#     assert flash.empty?
#   end

#   test "login with valid information followed by logout" do
#     post login_path, params: { session:{ email: @user.email,
#                                           password: 'password'
#     }}
#     assert is_logged_in? #ログインできているか
#     #リダイレクト先が正しいか
#     assert_redirected_to @user
#     #そのページに移動
#     follow_redirect!
#     assert_template 'users/show'
#     #ログイン時に表示されるものと表示されないものができているか確認
#     assert_select "a[href=?]", login_path, count: 0
#     assert_select "a[href=?]", logout_path
#     assert_select "a[href=?]", user_path(@user)
#     #ログアウトのテスト
#     delete logout_path
#     assert_not is_logged_in?
#     assert_response :see_other
#     assert_redirected_to root_path
#     follow_redirect!
#     assert_select "a[href=?]", login_path
#     assert_select "a[href=?]", logout_path, count: 0
#     assert_select "a[href=?]", user_path(@user), count: 0
#   end
# end
