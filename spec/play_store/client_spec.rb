require 'spec_helper'

describe CandyCheck::PlayStore::Client do
  include WithTempFile
  include WithFixtures

  with_temp_file :cache_file

  subject { CandyCheck::PlayStore::Client.new(config) }

  let(:config) do
    CandyCheck::PlayStore::Config.new(
      issuer: 'test_issuer',
      key_file: fixture_path('play_store', 'dummy.p12'),
      cache_file: cache_file_path,
      key_secret: 'notasecret'
    )
  end

  it 'fails if authentication fails' do
    mock_authorize!('auth_failure.txt')
    proc { subject.boot! }.must_raise Signet::AuthorizationError
  end

  it 'returns the products call result\'s data even if it is a failure' do
    bootup!

    mock_request!('products_failure.txt')
    -> { subject.verify('the_package', 'the_id', 'the_token') }
      .must_raise Google::Apis::AuthorizationError
  end

  it 'returns the products call result\'s data even if it is a failure' \
    ' when verifying subscription' do
    bootup!

    mock_subscriptions_request!('products_failure.txt')
    -> { subject.verify_subscription('the_package', 'the_id', 'the_token') }
      .must_raise Google::Apis::AuthorizationError
  end

  it 'returns the products call result\'s data for a successful call' do
    bootup!
    mock_request!('products_success.txt')
    result = subject.verify('the_package', 'the_id', 'the_token')
    result.must_be_instance_of Hash
    result[:purchase_state].must_equal 0
    result[:consumption_state].must_equal 0
    result[:developer_payload].must_equal \
      'payload that gets stored and returned'
    result[:purchase_time_millis].must_equal 1_421_676_237_413
    result[:kind].must_equal 'androidpublisher#productPurchase'
  end

  private

  def bootup!
    mock_authorize!('auth_success.txt')
    subject.boot!
  end

  def mock_authorize!(file)
    stub_request(:post, 'https://accounts.google.com/o/oauth2/token')
      .to_return(fixture_content('play_store', file))
  end

  def mock_request!(file)
    stub_request(:get, 'https://www.googleapis.com/androidpublisher/v2/' \
      'applications/the_package/purchases/products/the_id/tokens/the_token')
      .to_return(fixture_content('play_store', file))
  end

  def mock_subscriptions_request!(file)
    stub_request(:get, 'https://www.googleapis.com/androidpublisher/v2/' \
      'applications/the_package/purchases/subscriptions/' \
      'the_id/tokens/the_token')
      .to_return(fixture_content('play_store', file))
  end
end
