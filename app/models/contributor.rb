class Contributor < ApplicationRecord
  belongs_to :user
  belongs_to :package

  ROLE_AUTHOR = :author
  ROLE_MAINTAINER = :maintainer

end