# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:record) { create(:relationship) }

  describe 'バリデーション' do
    it '必要なパラメーターが揃っていれば有効であること' do
      expect(record).to be_valid
    end

    it_behaves_like 'requires belongs_to association', :follower
    it_behaves_like 'requires belongs_to association', :followed
  end

  describe 'データの一意性' do
    let(:other_relationship) { build(:relationship) }

    it '同じfollower_idとfollowed_idの組み合わせは無効であること' do
      invalid_relationship = build(
        :relationship,
        follower_id: record.follower_id,
        followed_id: record.followed_id
      )
      expect(invalid_relationship).to be_invalid
    end

    it 'follower_idが同じでもfollowed_idが異なる場合は有効であること' do
      same_follower = build(
        :relationship,
        follower_id: record.follower_id,
        followed_id: other_relationship.followed_id
      )
      expect(same_follower).to be_valid
    end

    it 'followed_idが同じでもfollower_idが異なる場合は有効であること' do
      same_followed = build(
        :relationship,
        follower_id: other_relationship.follower_id,
        followed_id: record.followed_id
      )
      expect(same_followed).to be_valid
    end
  end
end
