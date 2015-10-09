require 'bundler'
Bundler.require

[
	"./app.rb",
].each do |file|
	require file
end

