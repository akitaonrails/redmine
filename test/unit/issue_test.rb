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

require File.dirname(__FILE__) + '/../test_helper'

class IssueTest < Test::Unit::TestCase
  fixtures :projects, :users, :members,
           :trackers, :projects_trackers,
           :issue_statuses, :issue_categories,
           :enumerations,
           :issues,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries

  def test_it_should_delegate_task_code_to_tracker
    @issue = issues(:issues_001)
    assert_equal @issue.task_code, @issue.tracker.task_code
  end
  
  def test_category_based_assignment
    issue = Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 3, :status_id => 1, :priority => Enumeration.get_values('IPRI').first, :subject => 'Assignment test', :description => 'Assignment test', :category_id => 1)
    assert_equal IssueCategory.find(1).assigned_to, issue.assigned_to
  end
  
  def test_copy
    issue = Issue.new.copy_from(1)
    assert issue.save
    issue.reload
    orig = Issue.find(1)
    assert_equal orig.subject, issue.subject
    assert_equal orig.tracker, issue.tracker
    assert_equal orig.custom_values.first.value, issue.custom_values.first.value
  end
  
  def test_should_close_duplicates
    # Create 3 issues
    issue1 = Issue.new(:project_id => 1, :tracker_id => 1, :author_id => 1, :status_id => 1, :priority => Enumeration.get_values('IPRI').first, :subject => 'Duplicates test', :description => 'Duplicates test')
    assert issue1.save
    issue2 = issue1.clone
    assert issue2.save
    issue3 = issue1.clone
    assert issue3.save
    
    # 2 is a dupe of 1
    IssueRelation.create(:issue_from => issue2, :issue_to => issue1, :relation_type => IssueRelation::TYPE_DUPLICATES)
    # And 3 is a dupe of 2
    IssueRelation.create(:issue_from => issue3, :issue_to => issue2, :relation_type => IssueRelation::TYPE_DUPLICATES)
    # And 3 is a dupe of 1 (circular duplicates)
    IssueRelation.create(:issue_from => issue3, :issue_to => issue1, :relation_type => IssueRelation::TYPE_DUPLICATES)
        
    assert issue1.reload.duplicates.include?(issue2)
    
    # Closing issue 1
    issue1.init_journal(User.find(:first), "Closing issue1")
    issue1.status = IssueStatus.find :first, :conditions => {:is_closed => true}
    assert issue1.save
    # 2 and 3 should be also closed
    assert issue2.reload.closed?
    assert issue3.reload.closed?    
  end
  
  def test_should_not_close_duplicated_issue
    # Create 3 issues
    issue1 = Issue.new(:project_id => 1, :tracker_id => 1, :author_id => 1, :status_id => 1, :priority => Enumeration.get_values('IPRI').first, :subject => 'Duplicates test', :description => 'Duplicates test')
    assert issue1.save
    issue2 = issue1.clone
    assert issue2.save
    
    # 2 is a dupe of 1
    IssueRelation.create(:issue_from => issue2, :issue_to => issue1, :relation_type => IssueRelation::TYPE_DUPLICATES)
    # 2 is a dup of 1 but 1 is not a duplicate of 2
    assert !issue2.reload.duplicates.include?(issue1)
    
    # Closing issue 2
    issue2.init_journal(User.find(:first), "Closing issue2")
    issue2.status = IssueStatus.find :first, :conditions => {:is_closed => true}
    assert issue2.save
    # 1 should not be also closed
    assert !issue1.reload.closed?
  end
  
  def test_move_to_another_project_with_same_category
    issue = Issue.find(1)
    assert issue.move_to(Project.find(2))
    issue.reload
    assert_equal 2, issue.project_id
    # Category changes
    assert_equal 4, issue.category_id
    # Make sure time entries were move to the target project
    assert_equal 2, issue.time_entries.first.project_id
  end
  
  def test_move_to_another_project_without_same_category
    issue = Issue.find(2)
    assert issue.move_to(Project.find(2))
    issue.reload
    assert_equal 2, issue.project_id
    # Category cleared
    assert_nil issue.category_id
  end
  
  def test_issue_destroy
    Issue.find(1).destroy
    assert_nil Issue.find_by_id(1)
    assert_nil TimeEntry.find_by_issue_id(1)
  end
end
