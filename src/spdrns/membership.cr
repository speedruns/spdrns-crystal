module SpdRns
  struct Membership
    # Roles the User can play
    enum Role
      Participant # The user is part of the event (read + write)
      Observer    # The user is watching the event (read only)
    end

    # States the User can be in
    enum State
      Registered  # The user has promised to be present
      Joined      # The user is present, but is not fully prepared
      Ready       # The user is fully prepared to start
      Done        # The user successfully finished
      Failed      # The user failed to properly finish
      Forfeited   # The user voluntarily left the race
      Deserted    # The user abruptly left the race (e.g., rage-quit)
    end


    property user   : User
    property role   : Role
    property state  : State
    property time   : Time::Span?


    def initialize(@user, @role = Role::Observer, @state = State::Registered); end
    def self.participant(user); new(user, Role::Participant); end
    def self.observer(user);    new(user, Role::Observer);    end


    ### Roles
    def to_participant; to(Role::Participant);  end
    def to_observer;    to(Role::Observer);     end

    def to(role : Role)
      self.role = role
      self
    end


    ### State Transitions
    ACTIONS = [
      # Reversable actions
      :join,  :unjoin,
      :ready, :unready,
      :done,  :undone,
      # Non-reversable actions
      :fail,
      :forfeit,
      :desert
    ]

    def join(   race : Race);   transition(to: State::Joined);      end
    def unjoin( race : Race);   transition(to: State::Registered);  end
    def ready(  race : Race);   transition(to: State::Ready);       end
    def unready(race : Race);   transition(to: State::Joined);      end
    def done(   race : Race)
      transition(to: State::Done)
      self.time = race.elapsed_time
      self
    end
    def undone( race : Race);   transition(to: State::Ready);       end
    def fail(   race : Race);   transition(to: State::Failed);      end
    def forfeit(race : Race);   transition(to: State::Forfeited);   end
    def desert( race : Race);   transition(to: State::Deserted);    end

    def transition(to new_state : State, from old_states = nil)
      valid_transition = case old_states
      when State
        self.state == old_states
      when Array(State)
        old_states.includes?(self.state)
      else
        true
      end

      self.state = new_state if valid_transition
      self
    end

    def ready?; self.state.ready?; end
    def done?;  self.state.done?;  end
  end
end
