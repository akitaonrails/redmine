# Post to /resources/clients/create
# On success the resource will set the new location
# to /resources/clients/show/:id.  That location
# is not intended to be visible, but used to
# communicate the project's auto-assigned ID.
#
# ========
# Required
# ========
# <client>
#   <identifier>ccs</identifier>
#   <name>Client Name</name>
# </client>
# =========================
# Additional optional nodes
# =========================
# homepage
# is_public
# client description
#
class Resources::ClientsController < Resources::BaseController
  def model_class
    Project
  end
end
