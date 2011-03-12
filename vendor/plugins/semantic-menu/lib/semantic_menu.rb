require 'rubygems'
require 'action_view'
require 'active_support'

class MenuItem
  include ActionView::Helpers::TagHelper,
          ActionView::Helpers::UrlHelper
  
  attr_accessor :children, :link
  cattr_accessor :request
  
  def initialize(title, link, level, link_opts={})
    @title, @link, @level, @link_opts = title, link, level, link_opts
    @children = []
  end
  
  def add(title, link, link_opts={}, &block)
    returning(MenuItem.new(title, link, @level +1, link_opts)) do |adding|
      @children << adding
      yield adding if block_given?
    end
  end
  
  def to_s
    content_tag(:li, content_tag(:div, link_to(@title, @link, @link_opts), :class => "menu_header_level_"+@level.to_s) + child_output, ({:class => 'active'} if active?)).html_safe
  end
  
  def level_class
    "menu_level_#{@level}"
  end
  
  def child_output
    children.empty? ? '' : content_tag(:ul, @children.collect(&:to_s).join.html_safe, :class => level_class)
  end
  
  def active?
    children.any?(&:active?) || on_current_page?
  end
  
  def on_current_page?
    # set it for current_page? defined in UrlHelper
    # current_page?(@link)
    false
  end
  
  # def request
  #     @@request
  #   end
end

class SemanticMenu < MenuItem
  
  def initialize(rq, opts={},&block)
    @@request   = rq
    @opts       = {:class => 'menu'}.merge opts
    @level      = 0
    @children   = []
    yield self if block_given?
  end

  def to_s
    content_tag(:ul, @children.collect(&:to_s).join.html_safe, @opts).html_safe
  end
end
