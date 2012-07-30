# lib/**/*.rb
watch %r~lib/(.*)\.lua~ do |m|
	test "spec/#{m[1]}_spec.lua"
end

# spec/**/*_spec.rb
watch %r~spec/.*_spec\.lua~ do |m|
	test m[0]
end

# Ctrl-\
Signal.trap('QUIT') do
  puts "--- Running all tests ---\n\n"
	test "spec/tagen/*.lua"
end

def test(path)
	system "clear"
	cmd = "luaspec2 #{path}"
	puts cmd
	system cmd
end
