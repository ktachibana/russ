class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :validatable

  has_many :feeds, dependent: :destroy
  has_many :tags, dependent: :destroy
end
