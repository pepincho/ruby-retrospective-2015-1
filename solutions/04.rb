class Card < Struct.new(:rank, :suit)
  def to_s
    "#{rank.to_s.capitalize} of #{suit.to_s.capitalize}"
  end

  def ==(other)
    rank == other.rank and suit == other.suit
  end
end

class Deck
  include Enumerable

  SUITS = [:spades, :hearts, :diamonds, :clubs]

  def generate_all_cards(ranks)
    ranks.product(SUITS).collect { |x, y| Card.new(x, y) }
  end

  def initialize(cards = [])
    @ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
    @ranks_ascending = Hash[(0...@ranks.size).zip @ranks]
    cards.empty? ? @cards = generate_all_cards(@ranks) : @cards = cards
  end

  def each
    @cards.each { |card| yield card }
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.delete_at(0)
  end

  def draw_bottom_card
    @cards.delete_at(-1)
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort_by! { |x| [x.suit, @ranks_ascending.key(x.rank)] }.reverse!
  end

  def to_s
    @cards.map { |card| card.to_s + "\n" }.reduce(&:+)
  end

  def deal
    Hand.new(@cards, @ranks_ascending)
  end
end

class Hand
  SUITS = [:clubs, :diamonds, :hearts, :spades]

  def initialize(cards, ranks_ascending)
    @cards_hand = cards
    @ranks_ascending = ranks_ascending
  end

  def size
    @cards_hand.size
  end

  def to_s
    @cards_hand.map { |card| card.to_s + "\n" }.reduce(&:+)
  end
end

class WarDeck < Deck
  DECK_SIZE = 52
  CARDS_IN_HAND = 26

  def deal
    cards_hand = @cards[0..CARDS_IN_HAND - 1]
    @cards = @cards - cards_hand
    WarDeckHand.new(cards_hand, @ranks_ascending)
  end
end

class WarDeckHand < Hand
  def play_card
    @cards_hand.delete(@cards_hand.sample)
  end

  def allow_face_up?
    size <= 3 ? true : false
  end
end

class BeloteDeck < Deck
  DECK_SIZE = 32
  CARDS_IN_HAND = 8

  def initialize(cards = [])
    @ranks = [7, 8, 9, :jack, :queen, :king, 10, :ace]
    @ranks_ascending = Hash[(0...@ranks.size).zip @ranks]
    cards.empty? ? @cards = generate_all_cards(@ranks) : @cards = cards
  end

  def deal
    cards_hand = @cards[0..CARDS_IN_HAND - 1]
    @cards = @cards - cards_hand
    BeloteDeckHand.new(cards_hand, @ranks_ascending)
  end
end

class BeloteDeckHand < Hand

  def get_rank_key(card)
    @ranks_ascending.key(card.rank)
  end

  def highest_of_suit(suit)
    @cards_hand.select { |x| x.suit == suit }.
                max_by { |x| get_rank_key(x) }
  end

  def belote?
    SUITS.any? do |suit|
      has_queen = @cards_hand.include?(Card.new(:queen, suit))
      has_king  = @cards_hand.include?(Card.new(:king,  suit))

      has_queen && has_king
    end
  end

  def sort
    @cards_hand.sort_by { |x| [x.suit, get_rank_key(x)] }.reverse
  end

  def tierce?
    consecutive?(3)
  end

  def quarte?
    consecutive?(4)
  end

  def quint?
    consecutive?(5)
  end

  def carre_of_jacks?
    carre_of?(:jack)
  end

  def carre_of_nines?
    carre_of?(9)
  end

  def carre_of_aces?
    carre_of?(:ace)
  end

  private

  def carre_of?(rank)
    @cards_hand.count { |card| card.rank == rank } == 4
  end

  def consecutive?(length)
    sort.each_cons(length).each do |x|
      result = are_n_numbers_consecutive(length, x)
      if result then return true end
    end
    false
  end

  def are_n_numbers_consecutive(n, x)
    if x.all? { |a| a.suit == x[0].suit }
      are_consecutive = true
      return x.each_cons(2).all? { |x,y| ((get_rank_key(x) -
                                           get_rank_key(y)) == 1) }
    end
    false
  end
end

class SixtySixDeck < Deck
  DECK_SIZE = 24
  CARDS_IN_HAND = 6

  def initialize(cards = [])
    @ranks = [9, :jack, :queen, :king, 10, :ace]
    @ranks_ascending = Hash[(0...@ranks.size).zip @ranks]
    cards.empty? ? @cards = generate_all_cards(@ranks) : @cards = cards
  end

  def deal
    cards_hand = @cards[0..CARDS_IN_HAND - 1]
    @cards = @cards - cards_hand
    SixtySixDeckHand.new(cards_hand, @ranks_ascending)
  end
end

class SixtySixDeckHand < Hand

  def twenty?(trump_suit)
    pair_of_queen_and_king?(SUITS - [trump_suit])
  end

  def forty?(trump_suit)
    pair_of_queen_and_king?([trump_suit])
  end

  private

  def pair_of_queen_and_king?(allowed_suits)
    allowed_suits.any? do |suit|
      has_queen = @cards_hand.include?(Card.new(:queen, suit))
      has_king  = @cards_hand.include?(Card.new(:king, suit))

      has_queen && has_king
    end
  end
end
