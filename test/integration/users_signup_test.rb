require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    #登録ページにアクセスできるか
    get signup_path
    #POSTリクエスト前後でUser.countが変化しないかをチェックする
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar"}}
    end
    #正しいレスポンスが返され、正しいテンプレートがレンダリングされることを検証
    assert_response :unprocessable_entity
    assert_template 'users/new'
    #エラー表示が行われているかを確認
    assert_select 'div#error_explanation'
    assert_select 'div.alert-danger'
  end
  
  test "valid signup information" do
    assert_difference 'User.count', 1 do 
      post users_path, params: {user:{ name:  "Example User",
                                email: "user@example.com",
                                password:              "password",
                                password_confirmation: "password" } }
    end

    #指定されたリダイレクト先に飛ぶ
    follow_redirect!
    #showに飛ばされるはず
    assert_template 'users/show'
    #flashのテスト
    assert_not flash.empty?
    #サインアップ後にログインする
    assert is_logged_in?
  end
end
