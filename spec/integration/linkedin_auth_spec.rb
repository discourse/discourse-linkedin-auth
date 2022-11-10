# frozen_string_literal: true

describe 'LinkedIn OAuth2' do
  let(:access_token) { "linkedin_access_token_448" }
  let(:client_id) { "abcdef11223344" }
  let(:client_secret) { "adddcccdddd99922" }
  let(:temp_code) { "linkedin_temp_code_544254" }

  fab!(:user1) { Fabricate(:user) }

  def setup_linkedin_emails_stub(email:)
    if email
      body = {
        elements: [
          {
            "handle~": {
              emailAddress: email
            }
          }
        ]
      }
    else
      body = {}
    end
    stub_request(:get, "https://api.linkedin.com/v2/emailAddress?projection=(elements*(handle~))&q=members")
      .with(
        headers: {
          "Authorization" => "Bearer #{access_token}"
        }
      )
      .to_return(status: 200, body: JSON.dump(body), headers: { "Content-Type" => "application/json" })
  end

  before do
    SiteSetting.linkedin_enabled = true
    SiteSetting.linkedin_client_id = client_id
    SiteSetting.linkedin_secret = client_secret

    stub_request(:post, "https://www.linkedin.com/oauth/v2/accessToken")
      .with(
        body: hash_including(
          "client_id" => client_id,
          "client_secret" => client_secret,
          "code" => temp_code,
          "grant_type" => "authorization_code",
          "redirect_uri" => "http://test.localhost/auth/linkedin/callback"
        )
      )
      .to_return(
        status: 200,
        body: Rack::Utils.build_query(
          access_token: access_token,
          expires_in: 5184000,
          scope: "r_liteprofile r_emailaddress"
        ),
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded"
        }
      )
    stub_request(:get, "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))")
      .with(
        headers: {
          "Authorization" => "Bearer #{access_token}"
        }
      )
      .to_return(
        status: 200,
        body: JSON.dump(
          id: "4t4PH11YR7",
          profilePicture: {
            "displayImage~": {
              elements: [
                {
                  identifiers: [
                    {
                      identifier: "https://linkedin.com/imarge-url.jpg"
                    }
                  ]
                }
              ]
            }
          }
        ),
        headers: {
          "Content-Type" => "application/json"
        }
      )
  end

  # linkedin doesn't allow oauth2 logins unless the user has verified their email
  it "signs in the user whose email matches the email included in the API response from linkedin" do
    post "/auth/linkedin"
    expect(response.status).to eq(302)
    expect(response.location).to start_with("https://www.linkedin.com/oauth/v2/authorization")

    setup_linkedin_emails_stub(email: user1.email)

    post "/auth/linkedin/callback", params: {
      state: session["omniauth.state"],
      code: temp_code
    }
    expect(response.status).to eq(302)
    expect(response.location).to eq("http://test.localhost/")
    expect(session[:current_user_id]).to eq(user1.id)
  end
end
