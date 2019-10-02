# frozen_string_literal: true

# name: discourse-plugin-linkedin-auth
# about: Enable Login via LinkedIn
# version: 0.0.3
# authors: Matthew Wilkin
# url: https://github.com/cpradio/discourse-plugin-linkedin-auth

require 'auth/oauth2_authenticator'

gem 'omniauth-linkedin-oauth2', '1.0.0'

register_svg_icon "fab-linkedin-in" if respond_to?(:register_svg_icon)
register_asset 'stylesheets/linkedin-login.scss'

enabled_site_setting :linkedin_enabled

class LinkedInAuthenticator < ::Auth::OAuth2Authenticator
  PLUGIN_NAME = 'oauth-linkedin'

  def name
    'linkedin'
  end

  def after_authenticate(auth_token)
    result = super

    if result.user && result.email && (result.user.email != result.email)
      begin
        result.user.primary_email.update!(email: result.email)
      rescue
        used_by = User.find_by_email(result.email)&.username
        Rails.logger.warn("FAILED to update email for #{user.username} to #{result.email} cause it is in use by #{used_by}")
      end
    end

    result
  end

  def register_middleware(omniauth)
    omniauth.provider :linkedin,
                      setup: lambda { |env|
                        strategy = env['omniauth.strategy']
                        strategy.options[:client_id] = SiteSetting.linkedin_client_id
                        strategy.options[:client_secret] = SiteSetting.linkedin_secret
                      }
  end

  def enabled?
    SiteSetting.linkedin_enabled
  end
end

auth_provider frame_width: 920,
              frame_height: 800,
              icon: 'fab-linkedin-in',
              authenticator: LinkedInAuthenticator.new(
                'linkedin',
                trusted: true,
                auto_create_account: true
              )
