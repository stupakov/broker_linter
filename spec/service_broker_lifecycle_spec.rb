require 'faraday'
require 'json'
require 'securerandom'

describe 'service broker lifecycle' do
  it 'has a happy path' do
    username = 'admin'
    password = 'password'


    connection = Faraday.new(url: 'http://localhost:9292')
    connection.basic_auth(username, password)


    # FETCH CATALOG
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

    instance_id = "service-instance-#{SecureRandom.hex(4)}"
    binding_id = "service-binding-#{SecureRandom.hex(4)}"

    # CREATE INSTANCE
    create_instance_response = connection.put("/v2/service_instances/#{instance_id}", service_instance_attributes.to_json)
    expect([201, 200]).to include(create_instance_response.status)


    # BIND INSTANCE
    service_binding_attributes = {
      "service_id" =>        first_service_id,
      "plan_id" =>           first_plan_id,
      "app_guid" =>          "9999"
    }
    bind_instance_response = connection.put("/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}", service_binding_attributes.to_json)
    expect([201, 200]).to include(bind_instance_response.status)


    # UNBIND INSTANCE
    unbind_instance_response = connection.delete("/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}")
    expect([410, 200]).to include(unbind_instance_response.status)


    # DELETE INSTANCE
    delete_instance_response = connection.delete("/v2/service_instances/#{instance_id}")
    expect([410, 200]).to include(delete_instance_response.status)
  end
end
