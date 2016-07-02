class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :validatable, :rememberable

  has_many :subscriptions, dependent: :destroy
  has_many :feeds, through: :subscriptions
  has_many :items, through: :feeds
end
