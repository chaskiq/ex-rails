class Record < ApplicationRecord
  has_one_attached :avatar
  has_one_attached :favorite_tree_picture
  has_many_attached :images

  has_one_attached :minio_avatar, service: :minio
  has_one_attached :minio_favorite_tree_picture, service: :minio
  has_many_attached :minio_images, service: :minio
end
