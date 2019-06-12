require 'spec_helper'

describe CandyCheck::AppStore::Unified::VerifiedResponse do
  subject { CandyCheck::AppStore::Unified::VerifiedResponse.new(response) }

  describe 'when response does not include a subscription' do
    let(:response) do
      {
        'status' => 0,
        'environment' => 'Production',
        'receipt' => {
          'bundle_id' => 'com.app.bundle_id',
          'application_version' => '6',
          'receipt_creation_date' => '2017-07-25 00:55:46 Etc/GMT',
          'original_application_version' => '1.0',
          'in_app' => [
            {
              'quantity' => '1',
              'product_id' => 'com.app.product_id',
              'transaction_id' => '1000800359115195',
              'original_transaction_id' => '1000800359115195',
              'purchase_date' => '2017-12-14 16:54:33 Etc/GMT',
              'original_purchase_date' => '2017-12-14 16:29:35 Etc/GMT'
            }
          ]
        }
      }
    end

    let(:app_receipt_class) { CandyCheck::AppStore::Unified::AppReceipt }

    it '#subscription?' do
      subject.subscription?.must_be_false
    end

    it '#receipt' do
      subject.receipt.must_be_instance_of(app_receipt_class)
    end

    it '#pending_renewal_info' do
      subject.pending_renewal_info.must_be :empty?
    end
  end

  describe 'when respose includes a subscription' do
    let(:response) do
      {
        'status' => 0,
        'environment' => 'Production',
        'receipt' => {
          'bundle_id' => 'com.app.bundle_id',
          'application_version' => '6',
          'receipt_creation_date' => '2017-07-25 00:55:46 Etc/GMT',
          'original_application_version' => '1.0',
          'in_app' => [
            {
              'quantity' => '1',
              'product_id' => 'com.app.product_id',
              'transaction_id' => '1000800359115195',
              'original_transaction_id' => '1000800359115195',
              'purchase_date' => '2017-12-14 16:54:33 Etc/GMT',
              'original_purchase_date' => '2017-12-14 16:29:35 Etc/GMT',
              'expires_date' => '2017-12-14 16:59:33 Etc/GMT',
              'web_order_line_item_id' => '1000000037215974',
              'is_trial_period' => 'false',
              'is_in_intro_offer_period' => 'false'
            },
            {
              'quantity' => '1',
              'product_id' => 'com.app.alt.product_id',
              'transaction_id' => '1000800359115199',
              'original_transaction_id' => '1000800359115199',
              'purchase_date' => '2018-01-14 16:54:33 Etc/GMT',
              'original_purchase_date' => '2018-01-14 16:29:35 Etc/GMT',
              'expires_date' => '2018-01-14 16:59:33 Etc/GMT',
              'web_order_line_item_id' => '1000000037215975',
              'is_trial_period' => 'false',
              'is_in_intro_offer_period' => 'false'
            },
            {
              'quantity' => '1',
              'product_id' => 'com.app.alt.product_id',
              'transaction_id' => '1000800359205199',
              'original_transaction_id' => '1000800359115199',
              'purchase_date' => '2018-02-14 16:54:33 Etc/GMT',
              'original_purchase_date' => '2018-02-14 16:29:35 Etc/GMT',
              'expires_date' => '2018-02-14 16:59:33 Etc/GMT',
              'web_order_line_item_id' => '1000000039215975',
              'is_trial_period' => 'false',
              'is_in_intro_offer_period' => 'false'
            }
          ]
        },
        'latest_receipt_info' => [
          {
            'quantity' => '1',
            'product_id' => 'com.app.product_id',
            'transaction_id' => '1000800359115195',
            'original_transaction_id' => '1000800359115195',
            'purchase_date' => '2017-12-14 16:54:33 Etc/GMT',
            'original_purchase_date' => '2017-12-14 16:29:35 Etc/GMT',
            'expires_date' => '2017-12-14 16:59:33 Etc/GMT',
            'web_order_line_item_id' => '1000000037215974',
            'is_trial_period' => 'false',
            'is_in_intro_offer_period' => 'false'
          },
          {
            'quantity' => '1',
            'product_id' => 'com.app.product_id',
            'transaction_id' => '1000000359846977',
            'original_transaction_id' => '1000800359115195',
            'purchase_date' => '2017-12-15 08:17:54 Etc/GMT',
            'original_purchase_date' => '2017-12-14 16:29:35 Etc/GMT',
            'expires_date' => '2017-12-15 08:22:54 Etc/GMT',
            'web_order_line_item_id' => '1000000037216020',
            'is_trial_period' => 'false',
            'is_in_intro_offer_period' => 'false'
          },
          {
            'quantity' => '1',
            'product_id' => 'com.app.alt.product_id',
            'transaction_id' => '1000000359847977',
            'original_transaction_id' => '1000800359115199',
            'purchase_date' => '2018-01-15 08:17:54 Etc/GMT',
            'original_purchase_date' => '2018-01-14 16:29:35 Etc/GMT',
            'expires_date' => '2018-01-15 08:22:54 Etc/GMT',
            'web_order_line_item_id' => '1000000037216029',
            'is_trial_period' => 'false',
            'is_in_intro_offer_period' => 'false'
          }
        ],
        'latest_receipt' => 'base 64',
        'pending_renewal_info' => [
          {
            'expiration_intent' => '4',
            'auto_renew_product_id' => 'com.app.product_id',
            'original_transaction_id' => '1000800359115195',
            'is_in_billing_retry_period' => '0',
            'product_id' => 'com.app.product_id',
            'auto_renew_status' => '0'
          },
          {
            'expiration_intent' => '1',
            'auto_renew_product_id' => 'com.app.alt.product_id',
            'original_transaction_id' => '1000800359115199',
            'is_in_billing_retry_period' => '0',
            'product_id' => 'com.app.alt.product_id',
            'auto_renew_status' => '0'
          }
        ]
      }
    end

    let(:app_receipt_class) { CandyCheck::AppStore::Unified::AppReceipt }
    let(:in_app_class) { CandyCheck::AppStore::Unified::InAppReceipt }

    it '#subscription?' do
      subject.subscription?.must_be_true
    end

    it '#receipt' do
      subject.receipt.must_be_instance_of(app_receipt_class)
    end

    it '#latest_receipt_info' do
      subject.latest_receipt_info.size.must_equal 3
      subject.latest_receipt_info.last.must_be_instance_of(in_app_class)
    end

    it '#pending_renewal_info' do
      subject.pending_renewal_info.size.must_equal 2
      subject.latest_receipt_info.last.must_be_instance_of(in_app_class)
    end

    it '#in_app' do
      subject.in_app.size.must_equal 3
    end

    it '#subscriptions' do
      subject.subscriptions.size.must_equal 2
    end

    it '#latest_subscription_info' do
      subject.latest_subscription_info('1000800359115195').must_be_instance_of(in_app_class)
      subject.latest_subscription_info('1000800359115195').transaction_id.must_equal '1000000359846977'
    end

    # it '#pending_renewal_transaction' do
    #   subject.pending_renewal_transaction.must_be_instance_of(in_app_class)
    #   subject.pending_renewal_transaction.is_in_billing_retry_period.must_equal 0
    # end
  end
end
