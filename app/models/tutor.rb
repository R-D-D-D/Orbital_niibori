class Tutor < ApplicationRecord
  has_many :courses, dependent: :destroy
  has_many :messages, as: :chatroom
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save { email.downcase! }
  before_create :create_activation_digest
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, 
    presence: true, 
    length:     { maximum: 255 },
    format:     { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }

  validates :name,
    presence: true,
    length: { maximum: 50 }

  has_secure_password
  validates :password, 
    presence: true, 
    length: { minimum: 6 },
    allow_nil: true

  # Returns the hash digest of the given string.
  def Tutor.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? 
      BCrypt::Engine::MIN_COST : 
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def Tutor.new_token
    SecureRandom.urlsafe_base64
  end

  # Gets all students across all courses (NOT UNIQUE)
  def students
    Student
    .joins(subscriptions: :course)
    .where(courses: { tutor_id: self.id })
  end

  # Gets all unique students across all courses
  def students_unique
    Student
    .joins(subscriptions: :course)
    .where(courses: { tutor_id: self.id })
    .distinct
  end

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = Tutor.new_token
    update_columns(reset_digest:  Tutor.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Returns the tutor's notifications
  def notifications
    Notification.where(user_type: 'Tutor', user_id: self.id)
  end

  # Returns the tutor's unread notifications
  def notifications_unread
    notifications.where(read: false)
  end

  # Returns the tutor's read notifications
  def notifications_read
    notifications.where(read: true)
  end

  def Tutor.find_from_auth_hash(auth)
    Tutor.where(provider: auth.provider, uid: auth.uid).first
  end

  def Tutor.create_from_auth_hash(auth)
    password = Tutor.new_token
    tutor = Tutor.new(provider: auth.provider,
                          uid: auth.uid,
                          name: auth.info.name,
                          email: auth.info.email,
                          password: password,
                          password_confirmation: password,
                          activated: true,
                          activated_at: Time.zone.now)
    tutor.save
    return tutor
  end

  private

  def create_activation_digest
    self.activation_token = Tutor.new_token
    self.activation_digest = Tutor.digest(activation_token)
  end
end
