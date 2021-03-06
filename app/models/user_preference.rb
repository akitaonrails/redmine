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

class UserPreference < ActiveRecord::Base
  belongs_to :user
  serialize :others
  
  attr_protected :others
  
  def initialize(attributes = nil)
    super
    self.others ||= {}
  end
  
  def before_save
    self.others ||= {}
  end
  
  def [](attr_name)
    if attribute_present? attr_name
      super
    else
      others ? others[attr_name] : nil
    end
  end
  
  def []=(attr_name, value)
    if attribute_present? attr_name
      super
    else
      h = read_attribute(:others).dup || {}
      h.update(attr_name => value)
      write_attribute(:others, h)
      value
    end
  end
  
  def comments_sorting; self[:comments_sorting] end
  def comments_sorting=(order); self[:comments_sorting]=order end
end

# == Schema Info
# Schema version: 94
#
# Table name: user_preferences
#
#  id        :integer         not null, primary key
#  user_id   :integer         default(0), not null
#  hide_mail :boolean         
#  others    :text            
#  time_zone :string(255)     
#

