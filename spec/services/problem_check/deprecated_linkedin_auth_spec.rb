# frozen_string_literal: true

RSpec.describe ProblemCheck::DeprecatedLinkedInAuth do
  subject(:check) { described_class.new }

  describe ".call" do
    before { SiteSetting.stubs(linkedin_enabled: enabled) }

    context "when GitHub authentication is disabled" do
      let(:enabled) { false }

      it { expect(check).to be_chill_about_it }
    end

    context "when plugin is enabled" do
      let(:enabled) { true }

      it do
        expect(check).to have_a_problem.with_priority("high").with_message(
          "The discourse-linkedin-auth plugin is no longer supported, and LinkedIn OpenID Connect support has been added to Discourse core. You are recommended to update the authentication method in your LinkedIn app. Please see <a href='https://meta.discourse.org/t/discourse-linkedin-authentication/46818'>https://meta.discourse.org/t/discourse-linkedin-authentication/46818</a> for more information.",
        )
      end
    end
  end
end
