module Approval
  class Comment < ApplicationRecord
    self.table_name = :approval_comments

    def self.define_user_association
      belongs_to :user, polymorphic: true
    end

    belongs_to :request, class_name: :"Approval::Request", inverse_of: :comments
    validates :content, presence: true, length: { maximum: Approval.config.comment_maximum }
  end
end
