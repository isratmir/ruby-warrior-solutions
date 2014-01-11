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
    @went_back = false
  end

  def decide!
    @went_back = true if warrior.feel(:backward).wall?
    return :rescue! if warrior.feel.captive?
    return :attack! if warrior.feel.enemy?
    return :rest! if suit.damaged? && !suit.under_attack?
    return [:walk!, :backward] if can_go_back? || suit.under_attack? && suit.heavily_damaged?
    return [:rescue!, :backward] if warrior.feel(:backward).captive?

    :walk!
  end

  private
  attr_reader :suit
  def warrior
    suit.warrior
  end

  def can_go_back?
    !@went_back && warrior.feel(:backward).empty?
  end
end
