Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(3)
end

Given /^I enter my username into input field number (\d+)$/ do |field|
  step "I enter \"#{ENV["DATA_ACCEPTANCE_USER"]}\" into input field number #{field}"
end

Given /^I enter my password into input field number (\d+)$/ do |field|
  step "I enter \"#{ENV["DATA_ACCEPTANCE_PASSWORD"]}\" into input field number #{field}"
end
