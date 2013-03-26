class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  field :name, type: String
  field :body, type: String
  belongs_to :routine, dependent: :nullify
  belongs_to :user, dependent: :nullify
  validates_presence_of :name, :body
end
