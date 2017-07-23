require 'open-uri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    html = self.get_html(index_url)

    html.css(".student-card").collect do |student|
      {
        :name => student.css("a .student-name").text,
        :location => student.css("a .student-location").text,
        :profile_url => student.css("a").attribute("href").value
      }
    end
  end

  def self.scrape_profile_page(profile_url)
    html = self.get_html(profile_url)
    social_hash = self.build_social_hash(html)

    profile_hash = {
      :profile_quote => html.css(".profile-quote").text,
      :bio => html.css(".bio-block .description-holder").text.strip.gsub(/\s+/, " ")
    }

    profile_hash.merge!(social_hash)
  end

  def self.build_social_hash(html)
    social = html.css(".social-icon-container a")
    social_hash = {}

    if social.class == Nokogiri::XML::NodeSet
      social.each do |s|
        media = s.attribute("href").value
        if media.include?("twitter")
          social_hash.merge!({:twitter => media})
        elsif media.include?("github")
          social_hash.merge!({:github => media})
        elsif media.include?("linkedin")
          social_hash.merge!({:linkedin => media})
        else
          social_hash.merge!({:blog => media})
        end
      end
    end
    social_hash
  end

  def self.get_html(index_url)
    Nokogiri::HTML(open(index_url))
  end
end
