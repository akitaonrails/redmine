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

class Message < ActiveRecord::Base
  belongs_to :board
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  acts_as_tree :counter_cache => :replies_count, :order => "#{Message.table_name}.created_on ASC"
  has_many :attachments, :as => :container, :dependent => :destroy
  belongs_to :last_reply, :class_name => 'Message', :foreign_key => 'last_reply_id'
  
  acts_as_searchable :columns => ['subject', 'content'],
                     :include => {:board, :project},
                     :project_key => 'project_id',
                     :date_column => "#{table_name}.created_on"
  acts_as_event :title => Proc.new {|o| "#{o.board.name}: #{o.subject}"},
                :description => :content,
                :type => Proc.new {|o| o.parent_id.nil? ? 'message' : 'reply'},
                :url => Proc.new {|o| {:controller => 'messages', :action => 'show', :board_id => o.board_id}.merge(o.parent_id.nil? ? {:id => o.id} : 
                                                                                                                                       {:id => o.parent_id, :anchor => "message-#{o.id}"})}

  acts_as_activity_provider :find_options => {:include => [{:board => :project}, :author]}
    
  attr_protected :locked, :sticky
  validates_presence_of :subject, :content
  validates_length_of :subject, :maximum => 255
  
  def validate_on_create
    # Can not reply to a locked topic
    errors.add_to_base 'Topic is locked' if root.locked? && self != root
  end
  
  def after_create
    board.update_attribute(:last_message_id, self.id)
    board.increment! :messages_count
    if parent
      parent.reload.update_attribute(:last_reply_id, self.id)
    else
      board.increment! :topics_count
    end
  end
  
  def after_destroy
    # The following line is required so that the previous counter
    # updates (due to children removal) are not overwritten
    board.reload
    board.decrement! :messages_count
    board.decrement! :topics_count unless parent
  end
  
  def sticky?
    sticky == 1
  end
  
  def project
    board.project
  end
end

# == Schema Info
# Schema version: 94
#
# Table name: messages
#
#  id            :integer         not null, primary key
#  author_id     :integer         
#  board_id      :integer         not null
#  last_reply_id :integer         
#  parent_id     :integer         
#  content       :text            
#  locked        :boolean         
#  replies_count :integer         default(0), not null
#  sticky        :integer         default(0)
#  subject       :string(255)     default(""), not null
#  created_on    :datetime        not null
#  updated_on    :datetime        not null
#

