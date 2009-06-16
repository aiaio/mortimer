task(:recover_passwords) do
  $setup_disabled = true
  Rake::Task["environment"].invoke

  PasswordRecovery.recover!
end
