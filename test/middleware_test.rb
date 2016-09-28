require 'test_helper'

class MiddlewareTest < ActionDispatch::IntegrationTest
  def setup
    WebMock.reset!
  end

  def test_sends_data_for_transcribes_actions
    WebMock.disable_net_connect!(allow_localhost: false)
    stub_post = stub_request(:post, "http://api-transcript.herokuapp.com/api/v1/transactions")
    get '/posts/5'
    assert_requested(stub_post)
  end

  def test_only_runs_on_transcribed_actions
    WebMock.disable_net_connect!(allow_localhost: false)
    stub_post = stub_request(:post, "http://api-transcript.herokuapp.com/api/v1/transactions")
    post '/posts'
    assert_not_requested(stub_post)
  end

  def test_passes_additional_data
    WebMock.allow_net_connect!
    get '/posts/5'
    transaction = ApiTranscriptAgent::Sender.instance.last_sent_transaction_data
    assert_equal(transaction[:additional_data], {data: 'FOOBAR'})
  end
end
