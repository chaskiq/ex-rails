class Record < ApplicationRecord
  has_one_attached :avatar
  has_one_attached :favorite_tree_picture
end
