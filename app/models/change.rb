# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
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

class Change < ActiveRecord::Base
  belongs_to :changeset
  
  validates_presence_of :changeset_id, :action, :path
  
  def relative_path
    changeset.repository.relative_path(path)
  end
end

# == Schema Info
# Schema version: 94
#
# Table name: changes
#
#  id            :integer         not null, primary key
#  changeset_id  :integer         not null
#  action        :string(1)       default(""), not null
#  branch        :string(255)     
#  from_path     :string(255)     
#  from_revision :string(255)     
#  path          :string(255)     default(""), not null
#  revision      :string(255)     
#

