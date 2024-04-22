class Like < ApplicationRecord
  validates :user_id, presence: true
  validates :post_id, presence: true
  validates_uniqueness_of :post_id, scope: :user_id
  belongs_to :user
  belongs_to :post
end
