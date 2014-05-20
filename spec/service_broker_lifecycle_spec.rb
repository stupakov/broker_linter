require 'faraday'
require 'json'
require 'securerandom'

describe 'service broker lifecycle' do
  it 'has a happy path' do
    username = 'admin'
    password = 'password'
    # fetch catalog
    # pull the service and plan ids out of the catalog (get the first plan of first service)
    # issue a legit create instance request
    # bind it
    # unbind it
    # destroy it


    connection = Faraday.new(url: 'http://localhost:9292')
    connection.basic_auth(username, password)

    catalog_response  = connection.get('/v2/catalog')
    catalog = JSON.parse(catalog_response.body)

    first_service = catalog.fetch("services").first
    first_service_id = first_service.fetch("id")
    first_plan = first_service.fetch("plans").first
    first_plan_id = first_plan.fetch("id")

    service_instance_attributes = {
      "service_id" =>        first_service_id,
      "plan_id" =>           first_plan_id,
      "organization_guid" => "1234",
      "space_guid" =>        "5678"
    }

    instance_id = SecureRandom.hex(4)

    create_instance_response = connection.put("/v2/service_instances/#{instance_id}", service_instance_attributes.to_json)
    expect([201, 200]).to include(create_instance_response.status)

    delete_instance_response = connection.delete("/v2/service_instances/#{instance_id}")
    expect([410, 200]).to include(delete_instance_response.status)
  end
end
