require 'faraday'
require 'json'
require 'securerandom'
require 'broker_client'

describe 'service broker lifecycle' do
  it 'has a happy path' do
    username = 'admin'
    password = 'password'


    connection = Faraday.new(url: 'http://localhost:9292')
    connection.basic_auth(username, password)

    client = BrokerClient.new(connection)

    # FETCH CATALOG
    catalog_response  = connection.get('/v2/catalog')
    catalog = JSON.parse(catalog_response.body)

    first_service = catalog.fetch("services").first
    first_service_id = first_service.fetch("id")
    first_plan = first_service.fetch("plans").first
    first_plan_id = first_plan.fetch("id")



    instance_id = "service-instance-#{SecureRandom.hex(4)}"
    binding_id = "service-binding-#{SecureRandom.hex(4)}"


    # CREATE INSTANCE
    create_instance_status = client.create_instance({
      instance_id: instance_id,
      service_id: first_service_id,
      plan_id: first_plan_id
    })
    expect([201, 200]).to include(create_instance_status)


    # BIND INSTANCE
    bind_instance_status = client.bind_instance({
      instance_id: instance_id,
      binding_id: binding_id,
      service_id: first_service_id,
      plan_id: first_plan_id,
    })
    expect([201, 200]).to include(bind_instance_status)


    # UNBIND INSTANCE
    unbind_instance_status = client.unbind_instance({
      instance_id: instance_id,
      binding_id: binding_id,
    })
    expect([410, 200]).to include(unbind_instance_status)


    # DELETE INSTANCE
    delete_instance_status = client.delete_instance({
      instance_id: instance_id
    })
    expect([410, 200]).to include(delete_instance_status)
  end
end
