require 'test_helper'

class ApiTranscriptAgent::Sender
  def reset!
    @last_sent_transaction_data = nil
    @worker = Thread.new { work  }
    @http = Net::HTTP::Persistent.new(name: 'ApiTranscriptAgent')
  end
end

class MiddlewareTest < ActionDispatch::IntegrationTest
  def setup
    ApiTranscriptAgent::Sender.instance.reset!
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: false)
    @stub_post = stub_request(:post, "http://api-transcript.dev/api/v1/transactions")
  end

  def wait_for_last_transaction(timeout = 1)
    while timeout >= 0 do
      return if last_transaction
      timeout -= 0.1
      sleep 0.1
    end
  end

  def request(method, *args)
    send(method, *args)
    wait_for_last_transaction
  end

  def last_transaction
    ApiTranscriptAgent::Sender.instance.last_sent_transaction_data
  end

  def test_sends_data_for_transcribes_actions
    request :get, '/posts/5'
    assert_requested(@stub_post)
  end

  def test_only_runs_on_transcribed_actions
    post = Post.create!(author: 'Some guy', body: 'Some text')
    request :delete, "/posts/#{post.id}", as: :json
    assert_not_requested(@stub_post)
  end

  def test_passes_additional_data
    request :get, '/posts/5'
    assert_equal(last_transaction[:additional_data], {data: 'FOOBAR'})
  end

  def test_passes_response_body
    post = Post.create!(author: 'Some guy', body: 'Some text')
    request :get, "/posts/#{post.id}"
    response_json = JSON.parse(last_transaction[:response][:body])
    assert_equal(["Some guy", "Some text"], response_json.values_at('author', 'body'))
    assert_requested(@stub_post)
  end

  def test_passes_response_body_when_unprocessable
    post = Post.create!(author: 'Some guy', body: 'Some text')
    request :put, "/posts/#{post.id}", params: { post: { author: '' } }, as: :json
    assert_equal(response.status, 422)
    response_json = JSON.parse(last_transaction[:response][:body])
    assert_match("can't be blank", response_json['errors']['author'].first)
    assert_requested(@stub_post)
  end
end

