module SpdRns
  class User
    property name
    property races : Array(Race)

    def initialize(@name : String)
      @races = [] of Race
    end


    ### Membership
    def register(race : Race)
      race.add_participant(self)
      @races << race
    end

    def observe(race : Race)
      race.add_observer(self)
      @races << race
    end

    def leave(race : Race)
      race.remove_user(self)
    end


    ### State
    {% for action in Membership::ACTIONS %}
      def {{ action.id }}(race : Race)
        race.update_member(self) do |member|
          member.{{ action.id }}(race)
        end
      end
    {% end %}
  end
end

