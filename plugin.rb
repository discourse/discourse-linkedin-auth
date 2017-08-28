# name: discourse-plugin-linkedin-auth
# about: Enable Login via LinkedIn
# version: 0.0.2
# authors: Matthew Wilkin
# url: https://github.com/cpradio/discourse-plugin-linkedin-auth

require 'auth/oauth2_authenticator'

gem 'omniauth-linkedin-oauth2', '0.2.5'

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
        Rails.loger.warn("FAILED to update email for #{user.username} to #{result.email} cause it is in use by #{used_by}")
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
end

auth_provider title: 'with LinkedIn',
              enabled_setting: "linkedin_enabled",
              message: 'Log in via LinkedIn',
              frame_width: 920,
              frame_height: 800,
              authenticator: LinkedInAuthenticator.new(
                'linkedin',
                trusted: true,
                auto_create_account: true
              )

register_css <<CSS

.btn-social.linkedin {
  background: #46698f;
}

.btn-social.linkedin::before {
  content: $fa-var-linkedin;
}

CSS
