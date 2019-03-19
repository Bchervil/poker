class Card
	FACES = ['2', '3', '4', '5', '6', '7', '8', '9', '10',
			 'jack', 'queen', 'king', 'ace']
	SUITS = ['hearts', 'clubs', 'diamonds', 'spades']

	attr_reader :rank, :suit, :face

  def initialize(face, suit, rank)
  		@face = face
  		@suit = suit
  		@rank = rank
  	end

  	def show
  		@face + " " + @suit
  	end
  end

  class Deck

	def initialize
		@deck = Array.new
	end
	  def createDeck
		# fill deck
		@deck.clear
		Card::SUITS.each do |suit|
			rank = 1
			Card::FACES.each do |face|
				@deck << Card.new(face.upcase, suit.upcase, rank)
				rank += 1
			end
		end
	end

	public
