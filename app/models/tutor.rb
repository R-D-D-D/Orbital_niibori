class Tutor < ApplicationRecord
  has_many :courses, dependent: :destroy
  attr_accessor :remember_token, :activation_token
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

  private

  def create_activation_digest
    self.activation_token = Tutor.new_token
    self.activation_digest = Tutor.digest(activation_token)
  end
end
