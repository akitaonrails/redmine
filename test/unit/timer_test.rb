# redMine - project management software
# Copyright (C) 2008 Lightsky
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
require 'active_resource/http_mock'

class TimerTest < Test::Unit::TestCase
  class MockUser
    def login; 'login'; end
  end
  def test_with_authorization_scope_adjusts_the_site
    mock_user = MockUser.new

    assert_nil Timer.site.userinfo
    @yielded_user_info = ''
    Timer.with_authorization_scope(mock_user) do
      @yielded_user_info = Timer.site.userinfo
    end
    assert_match "#{mock_user.login}:#{MotherBrainResource.base_password}", @yielded_user_info
    assert_nil Timer.site.userinfo
  end

  def test_save_calls_validation
    timer = Timer.new({:task_code => nil, :redmine_exhibit_id => nil})
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post Timer.collection_path, Timer.headers, timer.to_xml, 201, 'Location' => '/timers/5'
    end
    
    assert ! timer.save
    assert timer.errors.on(:task_code)

  end
end