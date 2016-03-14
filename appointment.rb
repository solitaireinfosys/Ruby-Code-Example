class Appointment < ActiveRecord::Base
  belongs_to :user
  belongs_to :patient
  
  
  has_one :appointment_types_appointment  , :dependent=> :destroy
  has_one :appointment_type , :through => :appointment_types_appointment , :dependent=> :destroy
  accepts_nested_attributes_for :appointment_types_appointment , :allow_destroy => true
  
  has_one :appointments_business , :dependent=> :destroy
  has_one :business , :through => :appointments_business , :dependent=> :destroy
  accepts_nested_attributes_for :appointments_business , :allow_destroy => true 
  
  scope :active_appointment, ->{ where(status: true)}
  
  validates :repeat_by ,  :inclusion => { :in => %w(day week month),
    :message => "%{value} is not a valid repeat by" } , :allow => nil
    
  validates  :repeat_start , :repeat_end , :numericality => { :only_integer => true , :greater_than_or_equal_to => 1  } , :unless =>"repeat_by.nil? || repeat_by.blank?"
  validates   :patient_id , :appnt_date , :appnt_time , presence: true
  
  validates_presence_of  :user_id 
  
end
