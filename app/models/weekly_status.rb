# encoding: UTF-8
# Copyright 2014 innoQ Deutschland GmbH

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'modules/markdown'
require 'modules/authored'

class WeeklyStatus < ActiveRecord::Base
  include Markdown
  include Authored

  attr_accessible :status, :status_html

  has_many :comments, :as => :owner, :dependent => :destroy

  validates :status, :presence => true

  before_save :regenerate_html

  def self.recent
    order('id DESC')
  end

  def self.by_week(week)
    week_date = Time.now.beginning_of_year + week.to_i.weeks
    by_week_with_date(week_date)
  end

  def self.search(query)
    where('status LIKE ?', "%#{query}%")
  end

  def title
    timestamp = created_at? ? created_at : Time.now
    "Wochenstatus KW #{timestamp.strftime('%W')} von #{author}"
  end

  def regenerate_html
    self.status_html = md_to_html(status)
  end

  def self.statuses_in_previous_week(current_week)
    week_date = Time.now.beginning_of_year + current_week.to_i.weeks - 1.week
    by_week_with_date(week_date)
  end

  def self.statuses_in_next_week(current_week)
    week_date = Time.now.beginning_of_year + current_week.to_i.weeks + 1.week
    by_week_with_date(week_date)
  end

  private
  def self.by_week_with_date(date_in_week)
    where('created_at >= :start AND created_at <= :end',
          { :start => date_in_week.beginning_of_week, :end => date_in_week.end_of_week })
  end

end
