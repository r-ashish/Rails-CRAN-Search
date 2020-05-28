class User < ApplicationRecord
  def self.find_or_create(user_list)
    user_list.map do |user|
      self.where(name: user[:name], email: user[:email]).first_or_create
    end
  end
end