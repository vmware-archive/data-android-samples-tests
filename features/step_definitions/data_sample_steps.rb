Given /^I am on the Welcome Screen$/ do
  element_exists("view")
  sleep(3)
end

Given /^I enter my username into input field number (\d+)$/ do |field|
  step "I enter \"#{ENV["username"]}\" into input field number #{field}"
end

Given /^I enter my password into input field number (\d+)$/ do |field|
  step "I enter \"#{ENV["password"]}\" into input field number #{field}"
end
