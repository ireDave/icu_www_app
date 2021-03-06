require 'rails_helper'

describe Page do
  include_context "features"

  context "authorization" do
    let(:level1) { %w[admin] }
    let(:level2) { User::ROLES.reject { |r| level1.include?(r) }.append("guest") }
    let(:paths)  { [admin_session_info_path, admin_system_info_path, admin_test_email_path] }
    it "level 1 can view all pages" do
      level1.each do |role|
        login role
        paths.each do |path|
          visit path
          expect(page).to_not have_css(failure)
        end
      end
    end

    it "level 2 cannot view any pages" do
      level2.each do |role|
        login role
        paths.each do |path|
          visit path
          expect(page).to have_css(failure, text: unauthorized)
        end
      end
    end
  end
end
