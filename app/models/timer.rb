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

  attr_accessor :issue
  def initialize(attrs = {})
    attrs.symbolize_keys!
    if self.issue = attrs.delete(:issue)
      attrs[:task_code] = issue.task_code
      attrs[:redmine_exhibit_id] = issue.project_id
      attrs[:notes] = "#{issue[:id]} - #{issue.subject}"
      attrs[:redmine_issue_id] = issue[:id]
    end
    super(attrs)
  end
  
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
    ['redmine_exhibit_id', 'redmine_issue_id', 'notes'].each do |attribute|
      errors.add(attribute, 'cannot be blank') if !attributes.keys.include?(attribute) || send(attribute).nil? || send(attribute).blank?
    end
  end
end
