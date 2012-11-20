class Article < ActiveRecord::Base
  include ApplicationHelper

  attr_accessible :content, :title, :description, :tag_list
  acts_as_taggable

  belongs_to :user

  before_save :create_description

  validates :title, presence: true, length: { maximum: 60 }
  validates_presence_of :user_id

  default_scope order: 'articles.created_at DESC'

  def author_name
    user.username
  end

  private
  def create_description
    self.description = helpers.truncate(helpers.strip_tags(markdown_render(self.content)), :length => 300)
  end

  def helpers
    ActionController::Base.helpers
  end
end
