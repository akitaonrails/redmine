# redMine - project management software
# Copyright (C) 2006  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class ProjectCustomField < CustomField
  def type_name
    :label_project_plural
  end
end

# == Schema Info
# Schema version: 94
#
# Table name: custom_fields
#
#  id              :integer         not null, primary key
#  default_value   :text            
#  field_format    :string(30)      default(""), not null
#  is_filter       :boolean         not null
#  is_for_all      :boolean         not null
#  is_required     :boolean         not null
#  max_length      :integer         default(0), not null
#  min_length      :integer         default(0), not null
#  name            :string(30)      default(""), not null
#  position        :integer         default(1)
#  possible_values :text            
#  regexp          :string(255)     default("")
#  searchable      :boolean         
#  type            :string(30)      default(""), not null
#

