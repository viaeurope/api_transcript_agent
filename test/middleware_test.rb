require 'test_helper'

class MiddlewareTest < ActionDispatch::IntegrationTest
  def setup
    WebMock.reset!
  end

  def test_sends_data_for_transcribes_actions
    stub_post = stub_request(:post, "http://api-transcript.herokuapp.com/api/v1/transactions")
    get '/posts/5'
    assert_requested(stub_post)
  end

  def test_only_runs_on_transcribed_actions
    stub_post = stub_request(:post, "http://api-transcript.herokuapp.com/api/v1/transactions")
    post '/posts'
    assert_not_requested(stub_post)
  end
end
