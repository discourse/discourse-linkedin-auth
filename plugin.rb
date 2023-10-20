# frozen_string_literal: true

# name: discourse-linkedin-auth
# about: Provides the ability to use LinkedIn as a login option. 
# meta_topic_id: 46818
# version: 1.0
# authors: Matthew Wilkin
# url: https://github.com/discourse/discourse-linkedin-auth

gem "omniauth-linkedin-oauth2", "1.0.0"

register_svg_icon "fab-linkedin"

register_asset "stylesheets/common.scss"

enabled_site_setting :linkedin_enabled

class ::LinkedInAuthenticator < ::Auth::ManagedAuthenticator
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

auth_provider authenticator: ::LinkedInAuthenticator.new, icon: "fab-linkedin"
