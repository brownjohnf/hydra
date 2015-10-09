require 'json'

class Hydra < Sinatra::Base

	before do
		content_type "application/json"
	end

	get "/" do
		redirect "/status"
	end

	get '/status' do
		raw_response = `ps -efwww | grep [t]or`
		lines = raw_response.split("\n")
		ports = get_ports.map { |p| p[:port] }
		regions = get_regions.keys

		{
			num_regions: regions.length,
			num_ports: ports.length,
			num_processes: lines.length,
			port_range: [
				ports.min,
				ports.max,
			],
			ports: ports.sort,
			regions: regions.sort,
			tor_processes: lines.sort,
		}.to_json
	end

	get '/heartbeat' do
		status 200
		{
			data: "thump thump",
		}.to_json
	end

	get '/regions' do
		get_regions.to_json
	end

	get '/regions/:iso_code' do
		get_regions.select do |k, v|
			k == params[:iso_code]
		end.to_json
	end

	get '/ports' do
		get_ports.to_json
	end

	get '/ports/:port' do
		get_ports.select do |p|
			p[:port].to_s == params[:port]
		end.to_json
	end

	get '/ports/:port/test' do
		port = params[:port]

		{
			expected: find_port(port),
			actual: test_port(port),
		}.to_json
	end

	get '/ports/:port/restart' do
		port = params[:port]

		`kill #{get_pid_by_port(port)}`
		sleep 1

		redirect "/ports/#{port}"
	end

	private

	def find_port(port)
		get_ports.select do |n|
			n[:port] == port.to_i
		end[0]
	end


	def test_port(port)
		`curl -I --socks5 localhost:#{port} http://google.com | grep google`.split('/').select do |e|
			e =~ /google/
		end
	end

	def get_ports
		get_regions.invert.to_a.map do |a|
			a[0].map do |p|
				{
					port: p,
					iso_code: a[1],
					pid: get_pid_by_port(p),
				}
			end
		end.flatten
	end

	def get_pid_by_port(port)
		raw_response = `ps -efwww | grep [t]or`
		lines = raw_response.split("\n").select do |line|
			line =~ /tor_port_#{port}/
		end[0].split(' ')[1].to_i
	end

	def get_regions
		regions = {}

		raw_response = `ps -efwww | grep [t]or`
		lines = raw_response.split("\n")
		line_args = lines.map do |n|
			n.split('--').map do |p|
				case p
				when /socksport/i
					p.split(':')[-1]
				when /{\w\w}/
					p.split('{')[-1][0..1]
				end
			end.compact
		end.each do |el|
			regions[el[1]] ||= []
			regions[el[1]] << el[0].to_i
		end

		regions
	end

end

