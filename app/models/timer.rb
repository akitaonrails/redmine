class Timer < ActiveResource::Base
  class << self
    def with_authorization_scope(current_user)
      self.site = MotherBrainResource.base_site(current_user.login)
      yield if block_given?
    ensure
      self.site = MotherBrainResource.base_site
    end
  end
  self.site = MotherBrainResource.base_site

  def save
    validate
    if valid?
      super
    else
      nil 
    end
  end
  
  protected

  def validate
    errors.add('task_code', "is not in #{MotherBrainResource.valid_task_codes.inspect}") unless MotherBrainResource.valid_task_codes.include?(task_code)
    errors.add('redmine_exhibit_id', 'cannot be blank') if redmine_exhibit_id.nil? || redmine_exhibit_id.blank?
  end
end
