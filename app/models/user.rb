class User < ActiveRecord::Base
  #can't rely on rpx to give more than this
  validates_presence_of :identifier

  has_many :events
  has_many :friendships
  has_many :friends, :through => :friendships
  is_gravtastic!

  def self.search(search, page)
    paginate :per_page => 10, :page => page,
             :conditions => ['username like ? or email like ?', 
             "%#{search}%", "%#{search}%"], :order => 'username'
  end

  def self.find_or_create_with_rpx(data)
    user = self.find_by_identifier(data[:identifier])
    if user.nil?
      user = self.new
      user.identifier = data[:identifier]
      user.username = data[:preferredUsername]  || data[:username]
      user.email = data[:verifiedEmail] || data[:email]
      user.name = data[:displayName]
      user.save!
    end

    user
  end

  def is_friend? friend
    if self.friends(true).include?(friend)
      return true
    else
      return false
    end
  end

  def collect_events(curr_user_id)
    all_events = []
    self.events.each do |event|
      editable = (curr_user_id == event.user_id)
      all_events << event.to_timeline(editable)
    end
    self.friendships.each do |friendship|
      if friendship.selected
        more_events = Event.all_public(friendship.friend)
        more_events.each do |event|
          event.title = "[" + friendship.friend.username + "] " + event.title
          colored = event.to_timeline(false)
          colored.update({:color => "#c60"})
          all_events << colored
        end
      end
    end
    all_events
  end

end
