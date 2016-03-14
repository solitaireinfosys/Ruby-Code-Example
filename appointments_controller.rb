class AppointmentsController < ApplicationController
  respond_to :json
  before_filter :authorize
  before_action :find_company , :only =>[:index , :create , :edit , :show , :new]
  before_action :find_appointment , :only => [:show , :edit , :update , :destroy ]
  
  before_action :set_params_in_standard_format , :only=> [:create , :update] 
  
  # using only for postman to test API. Remove later  
  skip_before_filter :verify_authenticity_token, :unless => Proc.new { |c| c.request.format == 'application/json' }
  
  def index 
    appointments = @company.appointments.active_appointment.order("appointments.created_at desc").select("appointments.id , appointments.appnt_date , appointments.appnt_time , appointments.user_id , appointments.patient_id , appointments.created_at")
    
    result = []
    appointments.each do |appnt|
      item = {}
      item[:id] = appnt.id
      t1 = appnt.appnt_date.strftime("%a, %d %b %Y")
      t2 = appnt.appnt_time.strftime("%I:%M%P")
      item[:when] = t1 + " " + t2 
      business = appnt.business
      b_name = business.name
      b_city = business.city
      if b_city.nil? || b_city.blank?
        bs = b_name
      else
        bs = b_name + "(#{b_city})"
      end 
      item[:where] = bs
      item[:type] = appnt.appointment_types_appointment.appointment_type.name
      item[:practitioner] = appnt.user.full_name
      item[:patient] = appnt.patient.full_name
      item[:appointment_created_at] = appnt.created_at.strftime("%d %b %Y,%I:%M%p")
      result << item
    end
    
    render :json=> { appointments: result } 
    
  end
  
  def new 
    @appointment = Appointment.new
    result = {}
    result[:appnt_date] = @appointment.appnt_date
    result[:appnt_time] = @appointment.appnt_time
    result[:repeat_by] = @appointment.repeat_by
    result[:repeat_start] = @appointment.repeat_start
    result[:repeat_end] = @appointment.repeat_end
    result[:notes] = @appointment.notes
    result[:user_id] = @appointment.user_id
    result[:patient_id] = @appointment.patient_id
    render :json=> { appointment: result }
    
  end
  
  def create
    debugger 
    appointment  = @company.appointments.new(params_appointment)
    if appointment.valid?
      appointment.save
      result = {flag: true , id: appointment.id }
      render :json=> result
    else
      show_error_json(appointment.errors.messages)
    end 
  end
  
  def show
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  private
  
  def params_appointment
    params.require(:appointment).permit(:id , :user_id , :patient_id , :appnt_date , :appnt_time , :repeat_by , :repeat_start , :repeat_end , :notes , 
      :appointment_types_appointment_attributes => [:appointment_type_id],
      :appointments_business_attributes => [:business_id]
     )
  end
  
  def find_appointment
    @appointment = Appointment.find(params[:id])
  end
  
#   filter method to change params in structured format 
  def set_params_in_standard_format
    unless params[:appointment].nil?
      structure_format = {}
      structure_format[:id] = params[:appointment][:id] unless params[:appointment][:id].nil? 
      structure_format[:appnt_date] = params[:appointment][:appnt_date]
      structure_format[:appnt_time] = params[:appointment][:appnt_time]
      structure_format[:repeat_by] = params[:appointment][:repeat_by]
      structure_format[:repeat_start] = params[:appointment][:repeat_start]
      structure_format[:repeat_end] = params[:appointment][:repeat_end]
      structure_format[:user_id] = params[:appointment][:user_id]

#     when a new patient is created at appointment booking time  
      unless params[:appointment][:patient_id].nil?
        structure_format[:patient_id] = params[:appointment][:patient_id]
      else
        unless params[:appointment][:new_patient].blank? || params[:appointment][:new_patient].nil?
          patient = @company.patients.new(title: params[:appointment][:new_patient][:title], first_name: params[:appointment][:new_patient][:first_name], last_name: params[:appointment][:new_patient][:last_name] , dob: params[:appointment][:new_patient][:dob] , email: params[:appointment][:new_patient][:email] , reminder_type: params[:appointment][:new_patient][:reminder_type])
          if patient.valid?
            patient.save
            structure_format[:patient_id] = patient.id
          else
            structure_format[:patient_id] = nil                
          end
        else
          structure_format[:patient_id] = nil
        end    
      end
      
      
      appointment_type_item = {}
      appointment_type_item[:appointment_type_id]  = params[:appointment][:appointment_type_id]
      structure_format[:appointment_types_appointment_attributes] = appointment_type_item
      
      business_item = {}
      business_item[:business_id]  = params[:appointment][:business_id]
      structure_format[:appointments_business_attributes] = business_item
      params[:appointment] = structure_format 
    else
      structure_format = {}
      params[:appointment] = structure_format 
    end
    
  end
  
end