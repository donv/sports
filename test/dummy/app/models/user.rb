# frozen_string_literal: true

# Minimal stand-in for the host application's User model, which the engine depends on.
class User < ApplicationRecord
  def self.authenticate(email, _password)
    find_by(email: email)
  end

  def login
    email
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token = Digest::SHA1.hexdigest("#{email}--#{remember_token_expires_at}")
    save(validate: false)
  end
end
