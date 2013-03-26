class Tag
  include Mongoid::Document
  field :name, type: String
  validates :name, :uniqueness => { :case_sensitive => false }
  before_create :drop_case
  protected
  def drop_case
    self.name.capitalize!
  end
end
