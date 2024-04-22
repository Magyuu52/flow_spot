require 'rails_helper'

RSpec.describe Relationship, type: :model do
  describe 'データの保存機能' do
    let(:relationship) { create(:relationship) }
    
    it 'relationshipモデルに必要なパラメーターが揃っていれば有効であること' do
      expect(relationship).to be_valid
    end

    it 'relationshipモデルのfollower_idがnilの場合は無効であること' do
      relationship.follower_id = nil
      expect(relationship).to be_invalid
    end

    it 'relationshipモデルのfollowed_idがnilの場合は無効であること' do
      relationship.followed_id = nil
      expect(relationship).to be_invalid
    end
  end

  describe 'データの一意性' do
    let(:user) { create(:relationship) }
    let(:relationship) { build(:relationship) }

    it '自分自身はフォローをできないこと' do
      invalid_relationship = FactoryBot.build(:relationship, follower_id: user.follower_id, followed_id: user.followed_id)
      expect(invalid_relationship).to be_invalid
    end

    it 'フォロワーのユーザーのidが同じでも、フォローしているユーザーのidが異なる場合は有効であること' do
      same_follower_id_relationship = FactoryBot.build(:relationship, follower_id: relationship.follower_id, followed_id: user.followed_id)
      expect(same_follower_id_relationship).to be_valid
    end

    it 'フォロワーのユーザーのidが異なる場合、フォローしているユーザーのidが同じでも有効であること' do
      same_followed_id_relationship = FactoryBot.build(:relationship, follower_id: user.follower_id, followed_id: relationship.followed_id)
      expect(same_followed_id_relationship).to be_valid
    end
  end
end