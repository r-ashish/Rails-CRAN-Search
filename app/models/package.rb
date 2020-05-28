class Package < ApplicationRecord
  has_many :contributors, :dependent => :destroy

  def self.search(query)
    return all if query.blank?
    where('lower(name) LIKE ?', "%#{query.downcase}%")
  end

  def as_json
    json = super.as_json
    json[:authors] = self.authors.as_json(except: :id)
    json[:maintainers] = self.maintainers.as_json(except: :id)
    json
  end

  def authors
    self.contributors.where(role: Contributor::ROLE_AUTHOR).joins(:user).select("users.name", "users.email", "users.id")
  end

  def maintainers
    self.contributors.where(role: Contributor::ROLE_MAINTAINER).joins(:user).select("users.name", "users.email", "users.id")
  end

  def set_authors(users)
    creators_data = users.map do |user|
      {package: self, user: user, role: Contributor::ROLE_AUTHOR}
    end
    Contributor.create(creators_data)
  end

  def set_maintainers(users)
    creators_data = users.map do |user|
      {package: self, user: user, role: Contributor::ROLE_MAINTAINER}
    end
    Contributor.create(creators_data)
  end

end