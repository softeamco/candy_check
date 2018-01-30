require 'spec_helper'

describe CandyCheck::PlayStore::Verification do
  subject do
    CandyCheck::PlayStore::Verification.new(client, package, product_id, token)
  end
  let(:response) do
    {
      kind: 'androidpublisher#product_purchase',
      purchase_time_millis: 1_421_676_237_413,
      purchase_state: 0,
      consumption_state: 0,
      developer_payload: 'payload that gets stored and returned'
    }
  end
  let(:client)     { DummyGoogleClient.new(response) }
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

    it 'returns a receipt' do
      result = subject.call!
      result.must_be_instance_of CandyCheck::PlayStore::Receipt
      result.valid?.must_be_true
      result.consumed?.must_be_false
    end
  end

  describe 'failure' do
    before do
      def client.verify(_package, _product_id, _token)
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

  private

  DummyGoogleClient = Struct.new(:response) do
    attr_reader :package, :product_id, :token

    def boot!; end

    def verify(package, product_id, token)
      @package = package
      @product_id = product_id
      @token = token
      response
    end
  end
end
