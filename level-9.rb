class Player
  def initialize
    @suit = WarriorSuit.new(nil, 20)
    @brain = Brain.new(@suit)
  end

  def play_turn(warrior)
    @suit.warrior = warrior
    warrior.send(*@brain.decide!)
    @suit.last_turn_health = warrior.health
  end
end

class WarriorSuit
  attr_accessor :warrior, :last_turn_health
  def initialize(warrior, last_turn_health)
    @warrior = warrior
    @last_turn_health = last_turn_health
  end

  def heavily_damaged?
    warrior.health < 13
  end

  def damaged?
    warrior.health < 20
  end

  def under_attack?
    warrior.health < last_turn_health
  end
end

class Brain
  def initialize(suit)
    @suit = suit
    @eyes = Eyes.new
    @went_back = false
    @has_turned = false
  end

  def decide!
    @went_back = true if hands.feel(:backward).wall? || hands.feel(:backward).enemy?
    if hands.feel.wall? || double_back?
      @has_turned = true
      return :pivot!
    end
    return :rescue! if hands.feel.captive?
    return :attack! if hands.feel.enemy?
    return :shoot! if eyes.see_enemy?
    return :rest! if suit.damaged? && !suit.under_attack?
    return [:walk!, :backward] if can_go_back? || suit.under_attack? && suit.heavily_damaged?
    return [:rescue!, :backward] if hands.feel(:backward).captive?

    :walk!
  end

  private
  attr_reader :suit, :eyes
  def hands
    suit.warrior
  end

  def eyes
    @eyes.warrior = suit.warrior
    @eyes
  end

  def can_go_back?
    !@went_back && hands.feel(:backward).empty?
  end

  def double_back?
    eyes.see_enemy_behind? && suit.under_attack? && !@has_turned
  end
end

class Eyes
  attr_writer :warrior

  def see_enemy?
    warrior.look[1].enemy? || warrior.look[2].enemy?
  end

  def see_enemy_behind?
    warrior.look(:backward)[1].enemy? || warrior.look(:backward)[2].enemy?
  end

  private
  attr_reader :warrior
end
