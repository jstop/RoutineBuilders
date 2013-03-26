class Routine
  DAYS = %w(SU MO TU WE TH FR SA)
  include Mongoid::Document
  #include Mongoid::Paperclip

  field :title, type: String
  field :purpose, type: String
  field :resources, type: String
  field :weeks, type: Integer, :default => 1
  field :days, type: Array, :default => []
  field :hours, type: Integer, :default => 0
  field :minutes, type: Integer, :default => 0
  field :start_time, type: String
  field :tags, type: Array, :default => []
  field :image, type: String
  #field :routines_used, type: Array, :default => []
  field :used_by, type: Array, :default => []
  field :download_count, type: Integer, :default => 0
  field :public, type: Boolean, :default => true

  validates_presence_of :title, :purpose, :days
  #has_mongoid_attached_file :image,  
  #                  :storage => :s3,
  #                  :s3_credentials => S3_CREDENTIALS,
  #                  :path => "/:image/:filename"
  belongs_to :user, dependent: :nullify
  has_many :comments, dependent: :destroy

  def total_time_hours
    (self.weeks*self.days.count*(self.hours*60+self.minutes)/60).round
  end

  def total_time_minutes
    self.weeks*self.days.count*(self.hours*60+self.minutes)%60
  end

  def image_name
    if self.image == "category_1"
      "orange_clock.jpg"
    elsif self.image == "category_2"
      "running.jpeg"
    elsif self.image == "category_3"
      "Learn.jpeg"
    end
  end
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
end
