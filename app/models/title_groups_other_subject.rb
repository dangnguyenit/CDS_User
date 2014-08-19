class TitleGroupsOtherSubject < ActiveRecord::Base
  belongs_to :title_group
  belongs_to :other_subject
  belongs_to :cds_template
  
  attr_accessible :scoring, :title_id, :title_group_id, :other_subject_id, :cds_template_id
end
