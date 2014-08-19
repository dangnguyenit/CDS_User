class Photo < ActiveRecord::Base
  belongs_to :evidence
  attr_accessible :description, :image, :evidence_id

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => ""
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
