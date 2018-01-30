require 'spec_helper'

describe CandyCheck::PlayStore::SubscriptionVerification do
  subject do
    CandyCheck::PlayStore::SubscriptionVerification.new(
      client, package, product_id, token
    )
  end
  let(:response) do
    {
      kind: 'androidpublisher#subscriptionPurchase',
      start_time_millis: 1_459_540_113_244,
      expiry_time_millis: 1_462_132_088_610,
      auto_renewing: false,
      developer_payload: 'payload that gets stored and returned',
      cancel_reason: 0,
      payment_state: 1
    }
  end
  let(:client)     { DummyGoogleSubsClient.new(response) }
  let(:package)    { 'the_package' }
  let(:product_id) { 'the_product' }
  let(:token)      { 'the_token' }

  describe 'valid' do
    it 'calls the client with the correct paramters' do
      subject.call!
      client.package.must_equal package
      client.product_id.must_equal product_id
      client.token.must_equal token
    end

    it 'returns a subscription' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::Subscription
      result.expired?.must_be_true
    end
  end

  describe 'failure' do
    before do
      def client.verify_subscription(_package, _product_id, _token)
        raise Google::Apis::ClientError.new('Invalid request', status_code: 400)
      end
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal 400
      result.message.must_equal 'Invalid request'
    end
  end

  describe 'empty' do
    let(:response) do
      {}
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.code.must_equal(-1)
      result.message.must_equal('Malformed response')
    end
  end

  describe 'invalid response kind' do
    let(:response) do
      {
        'kind' => 'something weird'
      }
    end

    it 'returns a verification failure' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::VerificationFailure
      result.message.must_equal('Malformed response')
    end
  end

  private

  DummyGoogleSubsClient = Struct.new(:response) do
    attr_reader :package, :product_id, :token

    def boot!; end

    def verify_subscription(package, product_id, token)
      @package = package
      @product_id = product_id
      @token = token
      response
    end
  end
end
