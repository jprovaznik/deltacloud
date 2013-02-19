require 'rubygems'
require 'require_relative' if RUBY_VERSION < '1.9'

require_relative 'common.rb'

describe 'RhevmDriver Networks' do

  before do
    @driver = Deltacloud::new(:rhevm, credentials)
    VCR.insert_cassette __name__
  end

  after do
    VCR.eject_cassette
  end

  it 'must throw error when wrong credentials' do
    Proc.new do
      @driver.backend.networks(OpenStruct.new(:user => 'unknown', :password => 'wrong'))
    end.must_raise Deltacloud::Exceptions::AuthenticationFailure, 'Authentication Failure'
  end

  it 'must return list of networks' do
    @driver.networks.wont_be_empty
    @driver.networks.first.must_be_kind_of Network
  end

  it 'must allow to filter networks' do
    @driver.networks(:id => '00000000-0000-0000-0000-000000000009').wont_be_empty
    @driver.networks(:id => '00000000-0000-0000-0000-000000000009').must_be_kind_of Array
    @driver.networks(:id => '00000000-0000-0000-0000-000000000009').size.must_equal 1
    @driver.networks(:id => '00000000-0000-0000-0000-000000000009').first.id.must_equal '00000000-0000-0000-0000-000000000009'
    @driver.networks(:id => 'unknown').must_be_empty
  end

  it 'must allow to retrieve single network' do
    @driver.network(:id => '00000000-0000-0000-0000-000000000009').wont_be_nil
    @driver.network(:id => '00000000-0000-0000-0000-000000000009').must_be_kind_of Network
    @driver.network(:id => 'unknown').must_be_nil
  end

end
