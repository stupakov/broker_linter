require 'faraday'
require 'json'

describe 'fetching the catalog' do
  let(:connection) { Faraday.new(url: 'http://localhost:9292') }

  def fetch_catalog
    connection.get('/v2/catalog')
  end

  def authenticate(username, password)
    connection.basic_auth(username, password)
  end

  context 'when there are no credentials' do
    it 'returns a 401' do
      response = fetch_catalog

      expect(response.status).to eq(401)
    end
  end

  context 'when the credentials are obviously wrong' do
    it 'returns a 401' do
      authenticate('badguy', 'yourpassword')
      response = fetch_catalog

      expect(response.status).to eq(401)
    end
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
