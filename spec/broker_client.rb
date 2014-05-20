class BrokerClient
  class Logger
    def log(message)
      puts message
    end
  end

  def initialize(connection)
    @connection = connection
    @logger = Logger.new
  end

  def create_instance(options)
    logger.log "\n\nCreating instance: #{options.inspect}"
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

    create_instance_response.status
  end

  def bind_instance(options)
    logger.log "\n\nBinding instance: #{options.inspect}"
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

    bind_instance_response.status
  end

  def unbind_instance(options)
    logger.log "\n\nUnbinding instance: #{options.inspect}"

    instance_id = options.fetch(:instance_id)
    binding_id = options.fetch(:binding_id)

    unbind_instance_response = make_request(
      :delete,
      "/v2/service_instances/#{instance_id}/service_bindings/#{binding_id}",
      nil
    )

    unbind_instance_response.status
  end

  def delete_instance(options)
    logger.log "\n\nDeleting instance: #{options.inspect}"
    instance_id = options.fetch(:instance_id)

    delete_instance_response = make_request(
      :delete,
      "/v2/service_instances/#{instance_id}",
      nil
    )

    delete_instance_response.status
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
