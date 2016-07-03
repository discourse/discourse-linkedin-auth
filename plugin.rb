# name: discourse-plugin-oauth-linkedin
# about: Enable Login via LinkedIn
# version: 0.0.1
# authors: Matthew Wilkin
# url: https://github.com/cpradio/discourse-plugin-oauth-linkedin

enabled_site_setting :linkedin_login_enabled

gem 'omniauth-linkedin', '0.2.0'

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
    if SiteSetting.linkedin_login_enabled
      omniauth.provider :linkedin,
                        SiteSetting.linkedin_login_client_id,
                        SiteSetting.linkedin_login_client_secret_key
    end
  end
end


auth_provider :title => I18n.t('linkedin_login_title'),
              :message => I18n.t('linkedin_login_message'),
              :frame_width => 920,
              :frame_height => 800,
              :authenticator => LinkedInAuthenticator.new

register_css <<CSS

.btn-social.linkedin {
  background: #46698f;
}

.btn-social.linkedin:before {
  content: "\f08c";
}

CSS