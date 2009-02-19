task :setup do
  $setup_disabled = true
  Rake::Task["environment"].invoke
  env = ENV["RAILS_ENV"] || "DEVELOPMENT" 
  100.times { puts }
  puts "*****mortimer setup for #{env.upcase} environment:*****\n"
  AppSetup.go
end
