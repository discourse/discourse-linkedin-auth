# frozen_string_literal: true

class ProblemCheck::DeprecatedLinkedInAuth < ProblemCheck
  self.priority = "high"

  def call
    return no_problem if !SiteSetting.linkedin_enabled

    problem
  end
end
