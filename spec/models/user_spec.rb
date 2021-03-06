require 'rails_helper'

describe User do
  context "model validation" do
    it "the default factory user should be valid" do
      expect { create(:user) }.to_not raise_error
    end

    it "duplicate emails not allowed (case insensitive)" do
      user = create(:user)
      expect { create(:user, email: user.email) }.to raise_error(/email.*already.*taken/i)
      expect { create(:user, email: user.email.upcase) }.to raise_error(/email.*already.*taken/i)
    end

    it "encrypted password should be present" do
      expect { create(:user, encrypted_password: "") }.to raise_error(/password.*blank/i)
    end

    it "salt should have 32 characters" do
      expect { create(:user, salt: "abc") }.to raise_error(/salt.*length/i)
    end

    it "expiry date should be present" do
      expect { create(:user, expires_on: nil) }.to raise_error(/expires.*blank/i)
    end

    it "ICU ID should be positive" do
      expect { create(:user, player_id: nil) }.to raise_error(/not.*number/i)
      expect { create(:user, player_id: 0) }.to raise_error(/more.*than.*0/i)
    end
  end

  context "roles" do
    before(:each) do
      @roles_without_admin = User::ROLES.reject{ |r| r == "admin" }
      @non_admin_roles = @roles_without_admin.sort.join(" ")
      @non_admin_role = @roles_without_admin.sample
    end

    it "should be canonicalized" do
      expect(create(:user, roles: User::ROLES).roles).to eq("admin")
      expect(create(:user, roles: @roles_without_admin).roles).to eq(@non_admin_roles)
      expect(create(:user, roles: @roles_without_admin.shuffle.join("-")).roles).to eq(@non_admin_roles)
      expect(create(:user, roles: @non_admin_role).roles).to eq(@non_admin_role)
      expect(create(:user, roles: " ").roles).to be_nil
      expect(create(:user, roles: "").roles).to be_nil
      expect(create(:user, roles: nil).roles).to be_nil
      expect(create(:user, roles: "rubbish").roles).to be_nil
      expect(create(:user, roles: "rubbish invalid").roles).to be_nil
      expect(create(:user, roles: "rubbish invalid #{@non_admin_role}").roles).to eq(@non_admin_role)
      expect(create(:user, roles: " rubbish  invalid  #{@non_admin_role} ").roles).to eq(@non_admin_role)
    end

    it "none for the default factory user" do
      user = create(:user)
      expect(user.roles).to be_nil
      User::ROLES.each do |role|
        expect(user.send("#{role}?")).to be false
      end
    end

    it "all for the admin user" do
      user = create(:user, roles: "admin")
      expect(user.roles).to eq("admin")
      User::ROLES.each do |role|
        expect(user.send("#{role}?")).to be true
      end
    end

    it "multiple non-admin" do
      user = create(:user, roles: @roles_without_admin.shuffle.join(" "))
      expect(user.roles).to eq(@non_admin_roles)
      expect(user.admin?).to be false
      @roles_without_admin.each do |role|
        expect(user.send("#{role}?")).to be true
      end
    end

    it "single non-admin" do
      user = create(:user, roles: @non_admin_role)
      expect(user.roles).to eq(@non_admin_role)
      expect(user.admin?).to be false
      @roles_without_admin.each do |role|
        expect(user.send("#{role}?")).to eq(role == @non_admin_role)
      end
    end
  end

  context "#valid_password?" do
    it "default factory password should pass" do
      user = create(:user)
      expect(user.valid_password?("password")).to be true
      expect(user.valid_password?("drowssap")).to be false
    end

    it "random password should pass" do
      password = "password" + rand(1000).to_s
      salt = User.random_salt
      encrypted_password = User.encrypt_password(password, salt)
      user = create(:user, encrypted_password: encrypted_password, salt: salt)
      expect(user.valid_password?(password)).to be true
      expect(user.valid_password?(password.upcase)).to be false
    end
  end

  context "#authenticate!" do
    before(:each) do
      @user = create(:user)
      @addr = @user.email
      @pass = "password"
    end

    it "successful login" do
      expect(User.authenticate!(@addr, @pass)).to eql(@user)
    end

    it "invalid password" do
      expect { User.authenticate!(@addr, "bad") }.to raise_error("invalid_password")
    end

    it "unknown email" do
      expect { User.authenticate!("bad" + @addr, @pass) }.to raise_error("invalid_email")
    end

    it "subscription expired" do
      @user.expires_on = Date.yesterday
      @user.save
      expect { User.authenticate!(@addr, @pass) }.to raise_error("subscription_expired")
    end

    it "unverified email" do
      @user.verified_at = nil
      @user.save
      expect { User.authenticate!(@addr, @pass) }.to raise_error("unverified_email")
    end

    it "bad status" do
      @user.status = "Banned"
      @user.save
      expect { User.authenticate!(@addr, @pass) }.to raise_error("account_disabled")
    end
  end

  context "predicates" do
    let(:user) { create(:user) }

    it "#guest?" do
      expect(user.guest?).to be false
    end

    it "#member?" do
      expect(user.member?).to be true
    end
  end

  context "#season_ticket" do
    it "get" do
      user = create(:user)
      string = user.season_ticket
      expect(string).to match(/\A\w{4,}\z/)
      object = SeasonTicket.new(string)
      expect(object.icu_id).to eq(user.player_id)
      expect(object.expires_on).to eq(user.expires_on.to_s)
    end
  end

  context "#human_roles" do
    it "should translate roles" do
      expect(create(:user).human_roles).to eq("")
      expect(create(:user, roles: "admin").human_roles).to eq("Administrator")
      expect(create(:user, roles: "treasurer translator").human_roles).to eq("Translator Treasurer")
    end
  end

  context "#verification_param" do
    let(:user) { create(:user) }

    it "should be a fixed length hexidecimal" do
      expect(user.verification_param).to match /\A[a-f0-9]{10}\z/
    end
  end

  context "#for_subscribed_player" do
    it "should find existing user" do
      existing_user = create(:user)
      user = User.for_subscribed_player(existing_user.email)
      expect(user).to eq(existing_user)
    end

    it "should not find user with no player" do
      user = User.for_subscribed_player("no_email@no_email.com")
      expect(user).to be nil
    end

    it "should not find user with unsubscribed player" do
      player = create(:player)
      user = User.for_subscribed_player(player.email)
      expect(user).to be nil
    end

    it "should not find user with subscribed player" do
      player = create(:player)
      create(:paid_subscription_item, player: player)
      user = User.for_subscribed_player(player.email)
      expect(user).to_not be nil
    end
  end
end

describe User::Guest do
  let(:user) { User::Guest.new }

  it "#guest?" do
    expect(user.guest?).to be true
  end

  it "#member?" do
    expect(user.member?).to be false
  end

  it "roles" do
    User::ROLES.each do |role|
      expect(user.send("#{role}?")).to be false
    end
  end

  it "not allowed to report" do
    expect(user.disallow_reporting?).to be true
  end
end
