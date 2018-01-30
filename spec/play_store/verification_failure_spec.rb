require 'spec_helper'

describe CandyCheck::PlayStore::VerificationFailure do
  subject { CandyCheck::PlayStore::VerificationFailure.new(err) }

  describe 'denied' do
    let(:err) do
      Google::Apis::AuthorizationError.new(
        'The current user has insufficient permissions',
        status_code: 401
      )
    end

    it 'returns the code' do
      subject.code.must_equal 401
    end

    it 'returns the message' do
      subject.message.must_equal 'The current user has insufficient permissions'
    end
  end

  describe 'empty' do
    let(:err) { nil }

    it 'returns an unknown code' do
      subject.code.must_equal(-1)
    end

    it 'returns an unknown message' do
      subject.message.must_equal 'Unknown error'
    end
  end
end
