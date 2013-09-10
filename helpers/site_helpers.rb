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

  def recent_pins
    begin 
      getpins = Faraday.new(:url => 'https://ismaelc-pinterest.p.mashape.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      recent_pins = getpins.get do |req|
        req.url '/pins', :u => 'oneiota'
        req.headers['X-Mashape-Authorization'] = 'jGAjGHCTdlhTdzTM8COm8BQ1ButErG0b'
      end
      if recent_pins
        recent_pins = JSON.parse(recent_pins.body)
        recent_pins
      else
        false
      end
    rescue Exception
      puts e.message, e.backtrace
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
      puts e.message, e.backtrace
    end 
  end

  def dribbbles
    begin
      dribbble = Faraday.get 'http://api.dribbble.com/players/yarnell/shots.json'
      if dribbble
        dribbble = JSON.parse(dribbble.body)
        dribbble["shots"]
      else
        false
      end

    rescue Exception
      puts e.message, e.backtrace
    end 

  end

  def behances
    begin
      behance = Faraday.get 'http://www.behance.net/v2/users/jessicawalsh/projects?api_key=n8MGFFD05lRU0DK8rJ5t5fkmq57XwszW'
      if behance
        behance = JSON.parse(behance.body)
        behance["projects"]
      else
        false
      end

    rescue Exception
      puts e.message, e.backtrace
    end 
  end

  def clean_tweet tweet

    #regexps
    url = /( |^)http:\/\/([^\s]*\.[^\s]*)( |$)/
    user = /@(\w+)/

    #replace @usernames with links to that user
    while tweet =~ user
        tweet.sub! "@#{$1}", "<a href='http://twitter.com/#{$1}' >&#64#{$1}</a>"
    end

    #replace urls with links
    while tweet =~ url
        name = $2
        tweet.sub! /( |^)http:\/\/#{name}( |$)/, " <a href='http://#{name}' >#{name}</a> "
    end

    tweet

  end

  def clean_date date_created
    date_created = Time.at(date_created)
    date_created
  end

end