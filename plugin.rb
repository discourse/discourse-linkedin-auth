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

require_relative "lib/linked_in_authenticator"

auth_provider authenticator: ::LinkedInAuthenticator.new, icon: "fab-linkedin"

after_initialize do
  if SiteSetting.linkedin_enabled
    AdminDashboardData.add_problem_check do
      "The discourse-linkedin-auth plugin is no longer supported, and LinkedIn OpenID Connect support has been added to Discourse core. You are recommended to update the authentication method in your LinkedIn app. Please see https://meta.discourse.org/t/discourse-linkedin-authentication/46818 for more information."
    end
  end
end
