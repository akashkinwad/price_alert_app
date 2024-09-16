class Alert < ApplicationRecord
  belongs_to :user

  validates :coin_name, presence: true
  validates :target_price, presence: true, numericality: { greater_than: 0 }

  enum status: { created: 0, triggered: 1, deleted: 2 }

  after_commit :expire_user_alerts_cache

  private

  def expire_user_alerts_cache
    redis = Rails.cache.redis
    cache_prefix = "alerts/user-#{user_id}/"

    keys = redis.keys("#{cache_prefix}*")
    redis.del(*keys) if keys.any?
  end
end
