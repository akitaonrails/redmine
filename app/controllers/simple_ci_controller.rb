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

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class SimpleCiController < ApplicationController
  #unloadable
  layout 'base'
  before_filter :find_project, :authorize
  
  def show
    # Build the regular expression used to detect successfull builds
    success_re = Regexp.new(@project.ci_keyword.strip, Regexp::IGNORECASE)
    # Find the project's CI RSS feed URL
    # This URL is stored in a 'regular' project custom field
    feed_url = @project.ci_feed ? @project.ci_feed : ''
    #feed_url = feed_url.value if feed_url
    if !feed_url.blank?
      begin
        content = ''
        # Open the feed and parse it
        open(feed_url) do |s| content = s.read end
        rss = RSS::Parser.parse(content, false)
        if rss
          @builds = rss.items.collect do |item|
            build = {:time => item.date,
                     :title => item.title,
                     :description => item.description,
                     :url => item.link
                     }
            build[:success] = (success_re.match(item.title) ? true : false)
            build
          end
        else
          flash.now[:error] = l(:error_ci_feed_invalid) unless @builds
        end
      rescue SocketError
        flash.now[:error] = l(:error_ci_remote_host)
      end
    @show_descriptions = @project.ci_desc.to_i
    else
      flash.now[:error] = l(:error_ci_feed_not_defined)
    end
  end
  
private
  def find_project   
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
