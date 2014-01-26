class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :validatable, :rememberable

  has_many :feeds, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def subscribe(url, options = {})
    ActiveRecord::Base.transaction do
      feed = feeds.find_by(url: url) || feeds.load_by_url(url).tap(&:save!)
      return subscriptions.create!(options.merge(feed: feed))
    end
  end
end
