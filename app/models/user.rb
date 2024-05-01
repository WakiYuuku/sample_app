class User < ApplicationRecord
  
  attr_accessor :remember_token ,:activation_token, :reset_token  #記憶トークンを安全に使用する
  before_save   :downcase_email #コールバック
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  #特異メソッドの定義
  class << self
    #渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  
    #ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  
  end

  #こっちは特異クラスじゃないからすべてのUserインスタンスに影響を与えるのかな
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest") #self.が省略されてる
    #記憶トークンがnilだと例外処理が起こってしまうので、それを防ぐ
    return false if digest.nil?
    #Userインスタンスの持つ記憶トークンと比較している
    BCrypt::Password.new(digest).is_password?(token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  #アカウントを有効にする
  def activate 
    update_columns(activated: true, activated_at: Time.zone.now) #validationが行われないため注意
    #update_attribute(:activated, true)user.upadate_attributeが省略されている
  end

  #有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    #update_attribute(:reset_digest,  User.digest(reset_token))
    #update_attribute(:reset_sent_at, Time.zone.now)
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    #メールアドレスをすべて小文字にする
    def downcase_email
      self.email.downcase!
    end

    #有効化トークンとダイジェスを作成および代入
    def create_activation_digest
      self.activation_token = User.new_token #トークンの作成
      self.activation_digest = User.digest(activation_token) #ダイジェストの作成
    end


    
end
