# frozen_string_literal: true

class ProblemCheck::DeprecatedLinkedInAuth < ProblemCheck
  self.priority = "high"

  def call
    return no_problem if !SiteSetting.linkedin_enabled

    problem
  end

  private

  def message
    "The discourse-linkedin-auth plugin is no longer supported, and LinkedIn OpenID Connect support has been added to Discourse core. You are recommended to update the authentication method in your LinkedIn app. Please see <a href='https://meta.discourse.org/t/discourse-linkedin-authentication/46818'>https://meta.discourse.org/t/discourse-linkedin-authentication/46818</a> for more information."
  end
end
