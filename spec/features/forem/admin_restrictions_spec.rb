require 'spec_helper' 
require 'subscribem/testing_support/factories/account_factory' 
require 'subscribem/testing_support/authentication_helpers' 
feature "Forumscoping" do
	include Subscribem::TestingSupport::AuthenticationHelpers 
	let!(:account_a) { FactoryGirl.create(:account_with_schema) } 
	let!(:account_b) { FactoryGirl.create(:account_with_schema) } 
	before do
		Apartment::Database.switch(account_a.subdomain) 
		account_a.owner.forem_admin = true 
		account_a.owner.save
		Apartment::Database.reset
		account_b.users << account_a.owner 
	end
	# it "include user" do
	# 	account_a.owner.forem_admin.should == (account_a.owner)
	# end

	scenario "is only the forum admin for one account" do 
		sign_in_as(user: account_a.owner, account: account_a) 
		visit "http://#{account_a.subdomain}.example.com" 
		page.should have_content("Admin Area")
		visit "http://#{account_b.subdomain}.example.com" 
		page.should_not have_content("Admin Area")
	end 
end