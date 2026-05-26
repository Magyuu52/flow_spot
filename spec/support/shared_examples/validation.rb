# frozen_string_literal: true

RSpec.shared_examples "validates presence of" do |attribute|
  it "#{attribute} が空の場合は無効であること" do
    record.send("#{attribute}=", "")
    expect(record).to be_invalid
    expect(record.errors[attribute]).to be_present
  end
end

RSpec.shared_examples "validates max length of" do |attribute, max_length|
  it "#{attribute} が#{max_length}文字を超える場合は無効であること" do
    record.send("#{attribute}=", "a" * (max_length + 1))
    expect(record).to be_invalid
  end

  it "#{attribute} が#{max_length}文字以内の場合は有効であること" do
    record.send("#{attribute}=", "a" * max_length)
    expect(record).to be_valid
  end
end

RSpec.shared_examples "validates uniqueness of" do |attribute|
  it "重複した#{attribute}を持つレコードは無効であること" do
    duplicate = record.dup
    expect(duplicate).to be_invalid
    expect(duplicate.errors[attribute]).to be_present
  end
end

RSpec.shared_examples "requires belongs_to association" do |association|
  it "#{association}_id が nil の場合は無効であること" do
    record.send("#{association}_id=", nil)
    expect(record).to be_invalid
  end
end
