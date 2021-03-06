require 'json'
class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :screen_name, :twitter_token, :twitter_secret
  has_many :friendsrecords
  has_many :account_gender_judgments
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.screen_name = auth["info"]["nickname"]
      user.twitter_token =  auth['credentials']['token']
      user.twitter_secret = auth['credentials']['secret']
      puts auth['credentials']
    end
  end

  def all_friends
    unless self.friendsrecords.last.nil?
      Account.find(:all, :conditions=>['uuid IN (?)', JSON.parse(self.friendsrecords.last.friends)]) 
    else
      []
    end
  end

  def followbias
    return nil if self.friendsrecords.last.nil? or self.friendsrecords.last.friends == ""
    score = {:male=>0, :female=>0, :unknown=>0, :total_following=>0}
    self.all_friends.each do |account|
      score[:male] += 1 if account.gender=="Male"
      score[:female] += 1 if account.gender == "Female"
      score[:total_following] += 1
    end
    score[:unknown] = score[:total_following] - score[:male] - score[:female]
    score[:account] = self.screen_name
    score
  end
end
