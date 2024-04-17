class User < ApplicationRecord
  attr_accessor :remember_token #記憶トークンを安全に使用する

  before_save { email.downcase! }
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
  
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

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    #記憶トークンがnilだと例外処理が起こってしまうので、それを防ぐ
    return false if remember_digest.nil?
    #Userインスタンスの持つ記憶トークンと比較している
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  #ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  #セッションハイジャック防止のためにセッショントークンを返す
  #この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end
end
