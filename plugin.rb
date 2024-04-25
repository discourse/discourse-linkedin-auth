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
  require_relative "app/services/problem_check/deprecated_linkedin_auth"

  register_problem_check ProblemCheck::DeprecatedLinkedInAuth
end
