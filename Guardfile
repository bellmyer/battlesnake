guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.(rb|thor)$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb") { "spec" }
  watch(%r{spec/support/shared_examples/(.+).rb$}) { "spec" }
end
