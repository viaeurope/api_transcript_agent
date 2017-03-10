class Post < ApplicationRecord
  validates :author, :body, presence: true, length: { within: 3..255 }
end
