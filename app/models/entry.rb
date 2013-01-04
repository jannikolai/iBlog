require "modules/markdown"
require "modules/authored"
class Entry < ActiveRecord::Base
  include Markdown
  include Authored

  validates_presence_of :progress

  belongs_to :blog
  has_many :tags
  has_many :comments, :dependent => :destroy

  def tags_as_string
    tags.map { |t| t.name }.join(' ')
  end

  def tags_as_string=(tags_as_string)
    tags.destroy_all
    self.tags = tags_as_string.split(/,? /).map { |t| Tag.new(:name => t) }
  end

  before_save :regenerate_html

  def regenerate_html
    self.progress_html = md_to_html(progress)
    self.plans_html    = md_to_html(plans)
    self.problems_html = md_to_html(problems)
  end
end
