this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require 'stream_message_services_pb.rb'

def main
  message = ARGV.size > 0 ?  ARGV[0] : 'world'
  stub = Stream::Message::Stub.new('localhost:50051', :this_channel_is_insecure)
  begin
    response = stub.parse_request(Stream::Request.new(message: message))
    response.each do |row|
      p "Response: #{row.message}"
    end
  rescue GRPC::BadStatus => e
    abort "ERROR: #{e.message}"
  end
end

main
