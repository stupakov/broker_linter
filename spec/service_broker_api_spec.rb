require 'faraday'
require 'json'

describe 'service broker behavior' do
  def authenticate(username, password)
    connection.basic_auth(username, password)
  end

  def create_service_instance(id)
    connection.put("/v2/service_instances/#{id}")
  end

  let(:connection) { Faraday.new(url: 'http://localhost:9292') }

  describe 'fetching the catalog (GET /v2/catalog)' do
    def fetch_catalog
      connection.get('/v2/catalog')
    end

    context 'when the credentials are good' do
      let(:username) { 'admin' }
      let(:password) { 'password' }

      before {authenticate(username, password) }

      it 'returns a 200' do
        response = fetch_catalog

        expect(response.status).to eq(200)
      end

      it 'returns JSON content type' do
        response = fetch_catalog

        expect(response.headers['Content-Type']).to include('application/json')
      end

      it 'returns valid JSON in the body' do
        response = fetch_catalog

        expect{ JSON.parse(response.body)}.not_to raise_error
      end

      it 'has valid catalog content'
    end
  end

  describe 'creating a service instance (PUT /v2/service_instances/:id)' do
  end
end
