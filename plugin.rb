# frozen_string_literal: true

# name: discourse-linkedin-auth
# about: Enable Login via LinkedIn
# version: 1.0
# authors: Matthew Wilkin
# url: https://github.com/discourse/discourse-linkedin-auth

gem 'omniauth-linkedin-oauth2', '1.0.0'

register_svg_icon "fab-linkedin-in"

enabled_site_setting :linkedin_enabled

class ::LinkedInAuthenticator < ::Auth::ManagedAuthenticator
  def name
    'linkedin'
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

auth_provider authenticator: ::LinkedInAuthenticator.new,
              icon: 'fab-linkedin-in'
