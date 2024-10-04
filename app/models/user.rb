# app/models/user.rb
class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    validates :uid, presence: true, uniqueness: true
    has_many :roles
end