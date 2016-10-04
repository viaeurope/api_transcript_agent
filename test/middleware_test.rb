require 'test_helper'

class MiddlewareTest < ActionDispatch::IntegrationTest
  def setup
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: false)
    @stub_post = stub_request(:post, "http://api-transcript.dev/api/v1/transactions")
  end

  def test_sends_data_for_transcribes_actions
    get '/posts/5'
    assert_requested(@stub_post)
  end

  def test_only_runs_on_transcribed_actions
    post '/posts'
    assert_not_requested(@stub_post)
  end

  def test_passes_additional_data
    get '/posts/5'
    transaction = ApiTranscriptAgent::Sender.instance.last_sent_transaction_data
    assert_equal(transaction[:additional_data], {data: 'FOOBAR'})
  end

  def test_passes_response_body
    post = Post.create!(author: 'Some guy', body: 'Some text')
    get "/posts/#{post.id}"
    transaction = ApiTranscriptAgent::Sender.instance.last_sent_transaction_data
    response_json = JSON.parse(transaction[:response][:body])
    assert_equal(["Some guy", "Some text"], response_json.values_at('author', 'body'))
    assert_requested(@stub_post)
  end

  def test_passes_response_body_when_unprocessable
    post = Post.create!(author: 'Some guy', body: 'Some text')
    put "/posts/#{post.id}"
    transaction = ApiTranscriptAgent::Sender.instance.last_sent_transaction_data
    response_json = JSON.parse(transaction[:response][:body])
    assert_equal("must be set", response_json['errors']['author'])
    assert_requested(@stub_post)
  end

end
