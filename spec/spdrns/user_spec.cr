require "../spec_helper"

module SpdRns
  describe User do
    it "has a name" do
      user = User.new("user1")

      expect(user.name).to be_a(String)
      expect(user.name).to eq("user1")
    end

    it "keeps track of relevant races" do
      user = User.new("user1")
      race1 = Race.new

      user.register(race1)

      expect(user.races).to contain(race1)
    end

    it "can be in multiple races at once" do
      user = User.new("user1")
      race1, race2 = Race.new, Race.new

      user.register(race1)
      user.register(race2)

      expect(user.races).to contain(race1)
      expect(user.races).to contain(race2)
    end
  end
end
