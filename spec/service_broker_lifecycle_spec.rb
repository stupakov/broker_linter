require 'faraday'
require 'json'
require 'securerandom'
require 'broker_client'

describe 'service broker lifecycle' do
  it 'can fetch catalog and create/bind/unbind/delete instances' do
    username = 'admin'
    password = 'password'


    connection = Faraday.new(url: 'http://localhost:9292')
    connection.basic_auth(username, password)

    client = BrokerClient.new(connection)

    fetch_catalog_response = client.fetch_catalog
    expect(fetch_catalog_response[:status]).to eq(200)
    catalog = JSON.parse(fetch_catalog_response[:body])

    first_service = catalog.fetch("services").first
    first_service_id = first_service.fetch("id")
    first_plan = first_service.fetch("plans").first
    first_plan_id = first_plan.fetch("id")


    instance_id = "service-instance-#{SecureRandom.hex(4)}"
    binding_id = "service-binding-#{SecureRandom.hex(4)}"


    # CREATE INSTANCE
    create_instance_response = client.create_instance({
      instance_id: instance_id,
      service_id: first_service_id,
      plan_id: first_plan_id
    })
    expect([201, 200]).to include(create_instance_response[:status])


    # BIND INSTANCE
    bind_instance_response = client.bind_instance({
      instance_id: instance_id,
      binding_id: binding_id,
      service_id: first_service_id,
      plan_id: first_plan_id,
    })
    expect([201, 200]).to include(bind_instance_response[:status])


    # UNBIND INSTANCE
    unbind_instance_response = client.unbind_instance({
      instance_id: instance_id,
      binding_id: binding_id,
    })
    expect([410, 200]).to include(unbind_instance_response[:status])


    # DELETE INSTANCE
    delete_instance_response = client.delete_instance({
      instance_id: instance_id
    })
    expect([410, 200]).to include(delete_instance_response[:status])
  end
end
