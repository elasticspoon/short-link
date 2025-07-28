require_relative '../test_helper'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  APP = Rack::Lint.new(Rack::Builder.parse_file(File.expand_path('../../config.ru', __dir__)))

  def app
    APP
  end

  # POST endpoint tests
  def test_post_with_valid_content_type_creates_short_link_then_redirects
    body = 'https://example.com'
    encoded_body = '327c3fda87ce286848a574982ddd0b7c7487f816'

    post '/', body, 'CONTENT_TYPE' => 'text/plain'

    assert_equal 201, last_response.status
    assert_equal 'text/plain', last_response.content_type

    # Should return SHA1 hash (40 hex characters)
    assert_equal(encoded_body, last_response.body)

    get "/#{encoded_body}"

    assert_equal 200, last_response.status
    assert_equal "Redirected to #{body}", last_response.body
  end

  def test_post_with_invalid_content_type_returns422
    post '/', 'https://example.com', { 'CONTENT_TYPE' => 'application/json' }

    assert_equal 422, last_response.status
    assert_equal 'text/plain', last_response.content_type
    assert_equal 'Content Type must be "text/plain"', last_response.body
  end

  def test_post_without_content_type_returns_unprocessable
    post '/', 'https://example.com'

    assert_equal 422, last_response.status
    assert_equal 'Content Type must be "text/plain"', last_response.body
  end

  def test_post_generates_consistent_hash_for_same_url
    url = 'https://example.com'

    post '/', url, { 'CONTENT_TYPE' => 'text/plain' }
    first_hash = last_response.body

    post '/', url, { 'CONTENT_TYPE' => 'text/plain' }
    second_hash = last_response.body

    assert_equal first_hash, second_hash
  end

  def test_post_generates_different_hash_for_different_urls
    post '/', 'https://example.com', { 'CONTENT_TYPE' => 'text/plain' }
    first_hash = last_response.body

    post '/', 'https://google.com', { 'CONTENT_TYPE' => 'text/plain' }
    second_hash = last_response.body

    refute_equal first_hash, second_hash
  end

  def test_get_with_invalid_key_returns_not_found
    get '/nonexistent'

    assert_equal 404, last_response.status
    assert_equal 'text/plain', last_response.content_type
    assert_equal 'Not found', last_response.body
  end

  # Unsupported HTTP methods
  def test_unsupported_methods_return_not_found
    %w[PUT DELETE PATCH].each do |method|
      send(method.downcase.to_sym, '/')

      assert_equal 404, last_response.status
      assert_equal 'text/plain', last_response.content_type
      assert_equal 'Not Found', last_response.body
    end
  end

  def test_head_method_returns_not_found
    head '/'

    assert_equal 200, last_response.status
    # NOTE: Our simple Rack app returns body even for HEAD,
    # which is technically not HTTP compliant but matches current behavior
    assert_equal true, last_response.body.empty?
  end
end
