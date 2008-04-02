module Resources
  class BaseController < ApplicationController
    before_filter :authenticate
    before_filter :require_admin
    def create
      @object = model_class.new(params[object_node_hash_key])
      respond_to do |format|
        begin
          @object.save!
          format.xml  { render :xml => @object, :status => :created, :location => url_for(:action => 'show', :id => @object[:id]) }
        rescue ActiveRecord::RecordInvalid => e
          format.xml  { render :xml => @object.errors, :status => :unprocessable_entity }
        end
      end
    end

    def show
      @object = model_class.find(params[:id])
      render :xml => @object.to_xml
    end

    protected
    def require_login
      true
    end
    
    def model_class
      raise "define #{self.class}#model_class"
    end
    
    def object_node_hash_key
      model_class.to_s.underscore.to_sym
    end
    
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        User.current = User.try_to_login(username, password)
      end
    end
    
  end
end
