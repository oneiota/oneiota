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

  def intro_colors
    colorArray = [['#1B1464','#FFD295'],['#FFBD1A','#1010C1'], ['#FF39BD','#FFAF45']]
    pickedColors = colorArray.sample
    pickedColors
  end

  def get_projects
    projects = []
    projects = data.projects.drop(2).to_json
    projects
  end  

  def recent_pins
    begin
      getpins = Unirest::get("https://ismaelc-pinterest.p.mashape.com/oneiota/pins", 
        {
          "X-Mashape-Authorization" => "jGAjGHCTdlhTdzTM8COm8BQ1ButErG0b"
        }
      )
      if getpins
        recent_pins = JSON.parse(getpins.body.to_json)
        recent_pins
      else
        false
      end
    rescue Exception
      puts $!, $@
    end 
  end

  def tweets
    begin
      tweets = Twitter.user_timeline("oneiota_", {:count => 20, :trim_user => 1, :exclude_replies => 1, :include_entities => 1})
      if !tweets
        false
      else
        tweets
      end
    rescue Exception
      puts $!, $@
    end
  end

  def dribbbles
    begin
      dribbble = Faraday.get 'http://api.dribbble.com/players/oneiota/shots.json'
      if dribbble
        dribbble = JSON.parse(dribbble.body)
        dribbble["shots"]
      else
        false
      end

    rescue Exception
      puts $!, $@
    end 

  end

  def behances
    begin
      behance = Faraday.get 'http://www.behance.net/v2/users/oneiota/projects?api_key=ozONYd8dfUGe4RZof1iILLyglmviU61S'
      if behance
        behance = JSON.parse(behance.body)
        behance["projects"]
      else
        false
      end

    rescue Exception
      puts $!, $@
    end 
  end

  def clean_tweet tweet

    #regexps
    url = /( |^)http:\/\/([^\s]*\.[^\s]*)( |$)/
    user = /@(\w+)/

    #replace @usernames with links to that user
    while tweet =~ user
        tweet.sub! "@#{$1}", "<a target='_blank' href='http://twitter.com/#{$1}' >&#64#{$1}</a>"
    end

    #replace urls with links
    while tweet =~ url
        name = $2
        tweet.sub! /( |^)http:\/\/#{name}( |$)/, " <a target='_blank' href='http://#{name}' >#{name}</a> "
    end

    tweet

  end

  def clean_date date_created
    date_created = Time.at(date_created)
  end

  def clean_dribble_date dribbble_date
    dribbble_date = dribbble_date.gsub(/\//, "-")
    dribbble_date
  end

end