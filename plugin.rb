# name: discourse-plugin-linkedin-auth
# about: Enable Login via LinkedIn
# version: 0.0.1
# authors: Matthew Wilkin
# url: https://github.com/cpradio/discourse-plugin-linkedin-auth

gem 'omniauth-linkedin-oauth2', '0.1.5'

enabled_site_setting :linkedin_enabled

class LinkedInAuthenticator < ::Auth::Authenticator
  PLUGIN_NAME = 'oauth-linkedin'

  def name
    'linkedin'
  end

  def after_authenticate(auth_token)
    auth_result = Auth::Result.new

    linkedin_userid = auth_token[:uid]
    current_info = ::PluginStore.get(PLUGIN_NAME, "linkedin_userid_#{linkedin_userid}")

    auth_result.user = User.where(id: current_info[:user_id]).first if current_info
    auth_result.name = auth_token[:info][:name]
    auth_result.email = auth_token[:info][:email] if auth_token[:info][:email]
    auth_result.extra_data = { linkedin_userid: linkedin_userid }
    auth_result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set(PLUGIN_NAME, "linkedin_userid_#{data[:linkedin_userid]}", {user_id: user.id })
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

auth_provider :title => 'with LinkedIn',
              :message => 'Log in via LinkedIn',
              :frame_width => 920,
              :frame_height => 800,
              :authenticator => LinkedInAuthenticator.new

register_css <<CSS

.btn-social.linkedin {
  background: #46698f;
}

.btn-social.linkedin::before {
  content: $fa-var-linkedin;
}

CSS