#Markdown
set :markdown_engine, :redcarpet

#Livereload
activate :livereload

#bourbon
activate :bourbon

activate :blog do |blog|
  blog.paginate = true
  blog.per_page = 10
  blog.prefix = "feed"
  blog.permalink = "blog/:year/:title.html"
  Time.zone = "Brisbane"
end

#prettyURL's
activate :directory_indexes
page "/404.html", :directory_index => false

###
# Twitter Gem configure
###
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Twitter.configure do |config|
  config.consumer_key = 'LwohjV8Aui2hRqiOdGH27g'
  config.consumer_secret = 'GuGYzU47Y5ijUuulZJgYyVqQ9xbD9LAQOBQH0QxjQq4'
  config.oauth_token = '100129471-FMQnUYD7VHNYsCd8tlpxBiXzkIpEcBYHf3k3tHKY'
  config.oauth_token_secret = 'f52WfhoYW32lgyv7ppssMd9N0gE6an944mK9DIZQ'
end

set :site_desc, 'One iota is an agency of passionate designers & developers, focused on creating both brand & digital experiences that excite, motivate and add value'
# set :base_url, '/dev/'
set :base_url, '/'

### 
# Compass
###

# Susy grids in Compass
# First: gem install compass-susy-plugin
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
# 
# With no layout
# page "/path/to/file.html", :layout => false
# 
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
# 
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

# Assumes the file source/about/template.html.erb exists
data.projects.each do |project|
  proxy "/#{project.slug}.html", "/project-template.html", :locals => {:project => project}, :ignore => true, :layout => "single-layout"
end

###
# Helpers
###
page "/index.html", :layout => "layout"
page "/404.html", :layout => "404-layout"
page "/blood.html", :layout => "blood-layout"
page "/feed/*", :layout => "blog-single-layout"
page "/feed/index.html", :layout => "blog-layout"
page "/trans.html", :layout => "blank-layout"
# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# set :build_dir, '../public_html/dev'
set :build_dir, 'build'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css
  
  # Minify Javascript on build
  activate :minify_javascript

  # Minify HTML
  activate :minify_html

  # Use relative URLs
  activate :relative_assets

  # Add asset fingerprinting to avoid cache issues
  #activate :asset_hash, :ignore => [%r{^images/team/.*}, %r{^images/team-mask.svg},%r{^images/team-empty.svg}]

  # Create favicon/touch icon set from source/favicon_base.png
  # activate :favicon_maker

  # Serve GZIPPED FILES
  activate :gzip

  # require 'deployscript'
  # activate :deployScript

  # require 'imageresizer'
  # activate :image_resizer do |i|
  #   i.input_folders = ['/feed']
  #   i.size = '250x250'
  #   i.resize_method = :resize_to_fit
  #   i.name_prefix = 'thumb'
  #   i.name_extension = ''
  #   i.retina = false
  #   i.styles = []
  # end

  # Ignores
  ignore '/feed/calendar.html'
  ignore '/feed/tag.html'
  ignore 'oneiota.sublime-project'
  ignore 'oneiota.sublime-workspace'
  ignore '.htaccess'
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end
