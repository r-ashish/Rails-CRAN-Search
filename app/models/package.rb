class Package < ApplicationRecord
  has_many :contributors, :dependent => :destroy

  def authors
    self.contributors.where(role: Contributor::ROLE_AUTHOR)
  end

  def maintainers
    self.contributors.where(role: Contributor::ROLE_MAINTAINER)
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