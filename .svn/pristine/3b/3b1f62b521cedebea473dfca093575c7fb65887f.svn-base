class ScoringScale < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :scorings, :dependent => :destroy
  has_many :cds_templates
  has_many :other_subjects
end
