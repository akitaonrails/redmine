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

class Comment < ActiveRecord::Base
  belongs_to :commented, :polymorphic => true, :counter_cache => true
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

  validates_presence_of :commented, :author, :comments

  # Used in the views to anchor comments
  attr_accessor :indice
end

# == Schema Info
# Schema version: 94
#
# Table name: comments
#
#  id             :integer         not null, primary key
#  author_id      :integer         default(0), not null
#  commented_id   :integer         default(0), not null
#  commented_type :string(30)      default(""), not null
#  comments       :text            
#  created_on     :datetime        not null
#  updated_on     :datetime        not null
#

