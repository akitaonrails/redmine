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

class AuthSource < ActiveRecord::Base
  has_many :users
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :host, :maximum => 60
  validates_length_of :account_password, :maximum => 60, :allow_nil => true
  validates_length_of :account, :base_dn, :maximum => 255
  validates_length_of :attr_login, :attr_firstname, :attr_lastname, :attr_mail, :maximum => 30

  def authenticate(login, password)
  end
  
  def test_connection
  end
  
  def auth_method_name
    "Abstract"
  end

  # Try to authenticate a user not yet registered against available sources
  def self.authenticate(login, password)
    AuthSource.find(:all, :conditions => ["onthefly_register=?", true]).each do |source|
      begin
        logger.debug "Authenticating '#{login}' against '#{source.name}'" if logger && logger.debug?
        attrs = source.authenticate(login, password)
      rescue
        attrs = nil
      end
      return attrs if attrs
    end
    return nil
  end
end

# == Schema Info
# Schema version: 94
#
# Table name: auth_sources
#
#  id                :integer         not null, primary key
#  account           :string(255)     
#  account_password  :string(60)      
#  attr_firstname    :string(30)      
#  attr_lastname     :string(30)      
#  attr_login        :string(30)      
#  attr_mail         :string(30)      
#  base_dn           :string(255)     
#  host              :string(60)      
#  name              :string(60)      default(""), not null
#  onthefly_register :boolean         not null
#  port              :integer         
#  tls               :boolean         not null
#  type              :string(30)      default(""), not null
#

