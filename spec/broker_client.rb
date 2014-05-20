require 'json'

class BrokerClient
  class Logger
    def log(message)
    end

    def info(message)
      # puts ">>>#{message}"
    end
  end

  def initialize(connection)
    @connection = connection
    @logger = Logger.new
  end

  def fetch_catalog
    logger.info "Fetching catalog"
    catalog_response = make_request(:get, '/v2/catalog', {})
    {
      status: catalog_response.status,
      body: catalog_response.body
    }
  end

  def create_instance(options)
    logger.info"Creating instance: #{options.inspect}"
    instance_id = options.fetch(:instance_id)
    service_id = options.fetch(:service_id)
    plan_id = options.fetch(:plan_id)

    service_instance_attributes = {
      "service_id" =>        service_id,
      "plan_id" =>           plan_id,
      "organization_guid" => "1234",
      "space_guid" =>        "5678"
    }

    create_instance_response = make_request(:put, "/v2/service_instances/#{instance_id}", service_instance_attributes.to_json)

    {
      status: create_instance_response.status,
      body: create_instance_response.body
    }
  end

  def bind_instance(options)
    logger.info "Binding instance: #{options.inspect}"
    instance_id = options.fetch(:instance_id)
    binding_id = options.fetch(:binding_id)
    service_id = options.fetch(:service_id)
    plan_id = options.fetch(:plan_id)

    service_binding_attributes = {
      "service_id" =>        service_id,
      "plan_id" =>           plan_id,
      "app_guid" =>          "9999"
    }
    bind_instance_response = make_request(
      :put,
      "/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}",
      service_binding_attributes.to_json,
    )

    {
      status: bind_instance_response.status,
      body: bind_instance_response.body
    }
  end

  def unbind_instance(options)
    logger.info "Unbinding instance: #{options.inspect}"

    instance_id = options.fetch(:instance_id)
    binding_id = options.fetch(:binding_id)

    unbind_instance_response = make_request(
      :delete,
      "/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}",
      nil
    )

    {
      status: unbind_instance_response.status,
      body: unbind_instance_response.body
    }
  end

  def delete_instance(options)
    logger.info "Deleting instance: #{options.inspect}"
    instance_id = options.fetch(:instance_id)

    delete_instance_response = make_request(
      :delete,
      "/v2/service_instances/#{instance_id}",
      nil
    )

    {
      status: delete_instance_response.status,
      body: delete_instance_response.body
    }
  end

  private

  def make_request(type, url, body)
    logger.log "  >>making request:"
    logger.log "    method: #{type.upcase}"
    logger.log "    url: #{url}"
    logger.log "    body: #{body}"

    response = connection.send(type, url, body)

    logger.log "  >>response:"
    logger.log "    status: #{response.status}"
    logger.log "    body: #{response.body}"

    response
  end

  attr_reader :connection, :logger
end
