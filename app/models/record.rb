class Record
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  embedded_in :user
  field :routine_id, type: Moped::BSON::ObjectId
end
