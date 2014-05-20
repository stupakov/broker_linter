require 'broker_client'
require 'faraday'

describe 'authentication' do
  let(:connection) { Faraday.new(url: 'http://localhost:9292') }
  let(:client) { BrokerClient.new(connection) }

  def self.validate_authentication
    context 'when there are no credentials' do
      it 'returns a 401' do
        response = make_request
        expect(response[:status]).to eq(401)
      end
    end

    context 'when the credentials are obviously wrong' do
      it 'returns a 401' do
        connection.basic_auth('badguy', 'yourpassword')
        response = make_request

        expect(response[:status]).to eq(401)
      end
    end
  end

  describe 'the catalog endpoint' do
    let(:make_request) { client.fetch_catalog }

    validate_authentication
  end

  describe 'the create service instance endpoint' do
    let(:make_request) do
      client.create_instance({
        instance_id: '1234',
        plan_id: '1234',
        service_id: '4321'
      })
    end

    validate_authentication
  end

  describe 'the bind service instance endpoint' do
    let(:make_request) do
      client.bind_instance({
        instance_id: '1234',
        binding_id: '1234',
        plan_id: '1234',
        service_id: '4321'
      })
    end

    validate_authentication
  end

  describe 'the unbind service instance endpoint' do
    let(:make_request) do
      client.unbind_instance({
        instance_id: '1234',
        binding_id: '1234',
      })
    end

    validate_authentication
  end

  describe 'the delete service instance endpoint' do
    let(:make_request) do
      client.delete_instance({
        instance_id: '1234',
      })
    end

    validate_authentication
  end
end

