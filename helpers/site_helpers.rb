#!/bin/env ruby
# encoding: utf-8

module SiteHelpers

  def page_title
    title = "Iota"
    if data.page.title
      title << " — " + data.page.title
    elsif yield_content(:title)
      title << " — " + yield_content(:title)
    end
    title
  end
  
  def page_description
    if data.page.description
      description = data.page.description
    elsif yield_content(:description)
      description = yield_content(:description)
    else
      description = "We are one iota; a Brisbane based independent design agency driven by passion and a love for good design. We are skilled in identity and brand development, digital design, print and interactive media."
    end
    description
  end

  def get_projects
    projects = []
    projects = data.projects.drop(2).to_json
    projects
  end  

end