require "../spec_helper"
require "secure_random"

module SpdRns
  describe Race do
    it "has no default start time" do
      race = Race.new
      expect(race.start_time).to be_nil
    end

    it "has no default end time" do
      race = Race.new
      expect(race.end_time).to be_nil
    end

    it "has no default members" do
      race = Race.new
      expect(race.members.size).to eq(0)
    end

    it "can have multiple members" do
      race = Race.new
      race.open
      User.new("user1").register(race)
      User.new("user2").register(race)

      expect(race.members.size).to eq(2)
    end

    it "can update memberships in place" do
      race = Race.new
      user = User.new("user1")

      race.open
      user.register(race)

      user.join(race)
      expect(race.membership(user).state.joined?).to be_true
      expect(race.membership(user).state.ready?).to be_false

      user.ready(race)
      expect(race.membership(user).state.joined?).to be_false
      expect(race.membership(user).state.ready?).to be_true
    end

    it "starts in the 'Created' state" do
      race = Race.new
      expect(race.state).to eq(Race::State::Created)
    end


    context "when Open," do
      it "accepts new participants" do
        race = Race.new
        user = User.new("user")
        race.open

        expect(user.register(race)).to be_truthy
        expect(race.membership(user)).to be_truthy
      end

      it "accepts new observers" do
        race = Race.new
        user = User.new("user")
        race.open

        expect(user.observe(race)).to be_truthy
        expect(race.membership(user)).to be_truthy
      end
    end


    it "starts if all participants are ready" do
      race = Race.new
      user1 = User.new("user1")
      user2 = User.new("user2")

      race.open
      user1.register(race)
      user2.register(race)

      user1.ready(race)
      user2.ready(race)

      expect(race.start).to be_truthy
    end

    it "does not start if at least one participant is not ready" do
      race = Race.new
      user1 = User.new("user1")
      user2 = User.new("user2")

      race.open
      user1.register(race)
      user2.register(race)

      expect(race.start).to be_falsey
    end
  end
end
