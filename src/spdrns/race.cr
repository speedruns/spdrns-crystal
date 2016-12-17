module SpdRns
  class Race
    enum State
      Created     # Created, but not ready for registrations
      Open        # Accepting registrations
      Closed      # No longer accepting registrations
      Started     # Running and proceeding
      Paused      # Running but not proceeding
      Finished    # Done successfully
      Canceled    # Done, but not finished
    end

    macro ensure_state(state, ret_value=false)
      return {{ ret_value }} unless self.state == {{ state }}
    end

    def valid_actions
      case self.state
      when State::Created
        [:open, :cancel]
      when State::Open
        [:close]
      when State::Closed
        [:start, :cancel]
      when State::Started
        [:pause, :finish, :cancel]
      when State::Paused
        [:start, :cancel]
      when State::Finished
        [] of Symbol
      when State::Canceled
        [] of Symbol
      else
        [] of Symbol
      end
    end


    # Unique ID for the Race
    property id         : String
    # Time at which the Race timer starts
    property start_time : Time?
    # Time at which the Race timer ended (all participants finished/DOFd)
    property end_time   : Time?
    # List of members currently involved in the Race
    property members    : Array(Membership)
    # Current state of the Race
    property state      : State


    def initialize(@id="<none>")
      @start_time   = nil
      @end_time     = nil
      @members      = [] of Membership
      @state        = State::Created
    end

    def modify
    end

    def delete(reason : String = nil)
    end


    ### PARTICIPATION

    # Add the given User to the Race with a certain role
    def add_participant(user : User)
      ensure_state(State::Open)
      @members << Membership.participant(user)
    end

    def add_observer(user : User)
      @members << Membership.observer(user)
    end

    # Remove the given User's membership from the Race
    def remove_membership(user : User)
      @members.reject!{ |m| m.user == user }
    end

    # Return only the Memberships that are Participants in the Race
    def participants : Array(Membership)
      @members.select(&.role.participant?)
    end

    # Return only the Memberships that are Observers of the Race
    def observers : Array(Membership)
      @members.select(&.role.observer?)
    end

    # Return the Membership struct for the given User. Nil if the User is not a
    # member of the Race
    def membership?(user) : Membership | Nil
      @members.find{ |m| m.user == user }
    end

    # Same as #member, but assumes the Member exists.
    def membership(user) : Membership
      membership?(user).as(Membership)
    end

    # Find the Member struct for the given User, passing it to `block` and
    # replacing it in the Member list with the block's return value.
    def update_member(user, &block)
      case idx = _member_index(user)
      when Int
        @members[idx] = yield @members[idx]
      end
    end

    private def _member_index(user : User)
      @members.index{ |m| m.user == user }
    end


    ### EXECUTION

    def open; self.state = State::Open; end
    def close; self.state = State::Closed; end

    def start
      return false unless members.all?(&.ready?)
      @start_time = Time.now
      self.state = State::Started
    end

    def pause; self.state = State::Paused; end

    def finish
      @end_time = Time.now
      self.state = State::Finished
    end

    def cancel; self.state = State::Canceled; end

    def elapsed_time : Time::Span
      case start = @start_time
      when Time
        (@end_time || Time.now) - start
      else
        Time::Span.new(0)
      end
    end
  end
end
