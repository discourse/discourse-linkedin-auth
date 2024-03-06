# frozen_string_literal: true

class LinkedInAuthenticator < ::Auth::ManagedAuthenticator
  def name
    "linkedin"
  end

  def register_middleware(omniauth)
    omniauth.provider :linkedin,
                      setup:
                        lambda { |env|
                          strategy = env["omniauth.strategy"]
                          strategy.options[:client_id] = SiteSetting.linkedin_client_id
                          strategy.options[:client_secret] = SiteSetting.linkedin_secret
                        }
  end

  def enabled?
    SiteSetting.linkedin_enabled
  end

  # linkedin doesn't let users login with OAuth2 to websites unless they verify
  # their email address so whatever email we get from linkedin has to be
  # verified
  def primary_email_verified?(auth_token)
    true
  end
end
