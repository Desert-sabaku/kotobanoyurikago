require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      username: "testuser",
      password: "password123",
      password_confirmation: "password123"
    )
    # Avoid Devise confirmable sending mail (which requires controller mappings) in unit tests
    @user.skip_confirmation!
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should save a valid user" do
    assert @user.save
  end

  # Devise modules presence
  test "should include expected devise modules" do
    modules = User.devise_modules
    assert_includes modules, :database_authenticatable
    assert_includes modules, :registerable
    assert_includes modules, :recoverable
    assert_includes modules, :rememberable
    assert_includes modules, :validatable
    # confirmable and lockable are configured on the model
    assert_includes modules, :confirmable
    assert_includes modules, :lockable
  end

  # Email validation tests
  test "should require an email" do
    @user.email = nil
    assert_not @user.valid?
    assert @user.errors[:email].present?
  end

  test "should require a valid email format" do
    invalid_emails = %w[user@example user.example.com user@example. @example.com user@]

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should be invalid"
      assert @user.errors[:email].present?, "expected validation error for #{invalid_email}"
    end
  end

  test "should accept valid email formats" do
    valid_emails = %w[user@example.com USER@example.COM user.name@example.com user+tag@example.co.uk]

    valid_emails.each do |valid_email|
      @user.email = valid_email
      assert @user.valid?, "#{valid_email} should be valid"
    end
  end

  test "should require unique email" do
    @user.save
    duplicate_user = User.new(
      email: @user.email,
      username: "otheruser",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not duplicate_user.valid?
    assert duplicate_user.errors[:email].present?
  end

  test "should be case insensitive for email uniqueness" do
    @user.email = "Test@Example.COM"
    @user.save
    duplicate_user = User.new(
      email: "test@example.com",
      username: "otheruser2",
      password: "password123",
      password_confirmation: "password123"
    )
    assert_not duplicate_user.valid?
    assert duplicate_user.errors[:email].present?
  end

  # Password validation tests
  test "should require a password" do
    @user.password = nil
    @user.password_confirmation = nil
    assert_not @user.valid?
    assert @user.errors[:password].present?
  end

  test "should require password confirmation to match" do
    @user.password_confirmation = "different_password"
    assert_not @user.valid?
    assert @user.errors[:password_confirmation].present?
  end

  test "should require minimum password length" do
    @user.password = "12345"
    @user.password_confirmation = "12345"
    assert_not @user.valid?
    assert @user.errors[:password].present?
  end

  test "should accept password of minimum length" do
    @user.password = "123456"
    @user.password_confirmation = "123456"
    assert @user.valid?
  end

  test "should reject password exceeding maximum length" do
    long_password = "a" * 129
    @user.password = long_password
    @user.password_confirmation = long_password
    assert_not @user.valid?
    assert @user.errors[:password].present?
  end

  # Authentication tests
  test "should authenticate with valid password" do
    @user.save
    assert @user.valid_password?("password123")
  end

  test "should not authenticate with invalid password" do
    @user.save
    assert_not @user.valid_password?("wrong_password")
  end

  test "should encrypt password" do
    @user.save
    assert_not_nil @user.encrypted_password
    assert_not_equal "password123", @user.encrypted_password
  end

  # Password reset tests
  test "should generate reset password token" do
    @user.save
  # Do not call the mailer-backed helper in unit tests; generate token directly
  _raw_token, encrypted_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = encrypted_token
    @user.reset_password_sent_at = Time.current
    @user.save!

    assert_not_nil @user.reload.reset_password_token
    assert_not_nil @user.reset_password_sent_at
  end

  test "should reset password with valid token" do
    @user.save
    _, encrypted_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.reset_password_token = encrypted_token
    @user.reset_password_sent_at = Time.current
    @user.save!

    @user.reset_password("newpassword123", "newpassword123")
    assert @user.valid_password?("newpassword123")
  end

  # Remember me tests
  test "should remember user" do
    @user.save
    @user.remember_me!
    assert_not_nil @user.remember_created_at
  end

  test "should forget user" do
    @user.save
    @user.remember_me!
    @user.forget_me!
    assert_nil @user.remember_created_at
  end
end
