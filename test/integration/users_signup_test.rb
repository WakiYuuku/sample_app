require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear #メール配信を擬似的に格納しているdeliveriesをクリアする
  end
end

class UsersSignupTest < UsersSignup
  test "invalid signup information" do
    #POSTリクエスト前後でUser.countが変化しないかをチェックする
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                          email:                 "user@invalid",
                                          password:              "foo",
                                          password_confirmation: "bar"}}
    end
    #正しいレスポンスが返され、正しいテンプレートがレンダリングされることを検証
    assert_response :unprocessable_entity
    assert_template 'users/new'
    #エラー表示が行われているかを確認
    assert_select 'div#error_explanation'
    assert_select 'div.alert-danger'
  end
  
  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: {user: {name:  "Example User",
                                      email: "user@example.com",
                                      password:              "password",
                                      password_confirmation: "password" }}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size #メールが１通になっているか
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params:{user: { name:  "Example User",
                                      email: "user@example.com",
                                      password:              "password",
                                      password_confirmation: "password"}}
    @user = assigns(:user)
  end
  
  test "should not be activated" do
    assert_not @user.activated?
  end

  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email) #メールに添付されるアカウント有効化URL
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: "wrong")
    assert_not is_logged_in?
  end

  test "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated? #リロードを行い有効化されているかを確認
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end

end
