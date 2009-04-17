class Resources::ExhibitsController < Resources::BaseController
  def create
    if value = params[object_node_hash_key]
      if value[:parent_id].blank?
        render :xml => "<errors><error>parent_id is required</error></errors>", :status => :unprocessable_entity
        return
      end
    end
    super
  end
  
  protected
  
  def model_class
    Project
  end
  
end
