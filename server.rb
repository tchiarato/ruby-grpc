this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'grpc/health/checker'
require 'grpc/health/v1/health_services_pb'
require 'openssl'
require 'optparse'

require 'stream_message_services_pb.rb'

class MessageServer < Stream::Message::Service
  def parse_request(request, grpc_call)
    ResponseEnum.new((1..10), request.message).each
  end
end

class ResponseEnum
  def initialize(range, name)
    @range = range
    @name = name
  end

  def each
    return enum_for(:each) unless block_given?

    @range.each do |index|
      yield Stream::Response.new(message: "##{index}: Hello #{@name}!")
      sleep 1
    end
  end
end

def main
  s = GRPC::RpcServer.new
  # Listen on port 50051 on all interfaces. Update for production use.
  s.add_http2_port('[::]:50051', :this_port_is_insecure)
  s.handle(MessageServer.new)

  health_checker = Grpc::Health::Checker.new
  health_checker.add_status(
      "MessageService",
      Grpc::Health::V1::HealthCheckResponse::ServingStatus::SERVING)
  s.handle(health_checker)
  s.run_till_terminated
end

if __FILE__ == $0
  main()
end