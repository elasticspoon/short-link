require_relative '../test_helper'
require 'net/http'
require 'uri'

class HttpIntegrationTest < Minitest::Test
  BASE_URL = 'http://localhost:3000'

  def setup
    uri = URI(BASE_URL)
    Net::HTTP.get_response(uri)
  rescue Errno::ECONNREFUSED, SocketError
    skip "⚠️  Server not running on #{BASE_URL}. Start with: bin/serve"
  end

  def test_full_workflow_via_http
    url = 'https://example.com/integration-test'
    encoded_url_one = '15ecf5'
    encoded_url_two = 'e99c00'
    uri = URI("#{BASE_URL}/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'text/plain'
    request.body = url

    response = http.request(request)

    assert_equal '201', response.code
    assert_equal(encoded_url_one, response.body)

    key = response.body

    get_uri = URI("#{BASE_URL}/#{key}")
    get_response = Net::HTTP.get_response(get_uri)

    assert_equal '301', get_response.code
    assert_equal url, get_response.header['location']

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'text/plain'
    request.body = url

    response = http.request(request)

    assert_equal '201', response.code
    assert_equal(encoded_url_two, response.body)

    key = response.body

    get_uri = URI("#{BASE_URL}/#{key}")
    get_response = Net::HTTP.get_response(get_uri)

    assert_equal '301', get_response.code
    assert_equal url, get_response.header['location']
  end
end
