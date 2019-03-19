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
	  def shuffle
		createDeck
		@deck.shuffle!
	end

	def drawCard
		#remove top card from deck and pass back
		if @deck.empty?
			raise "No Cards Left in Deck!" #should never happen
		else
			@deck.delete_at(0)
		end
	end
end
class Hand
	attr_reader :bestHand

	def initialize
		@hand = Array.new
		@handAnalysis = Array.new(13,0)  
		@suitAnalysis = Hash.new(0) 
		@pokerRanking = {'Royal Flush' => 1, 'Straight Flush' => 2,
						 'Four of a Kind' => 3, 'Full House' => 4,
					     'Flush' => 5, 'Straight' => 6 ,
					     'Triples' => 7, 'Two Pairs' => 8,
					     'Pair' => 9, 'High Card' => 10}
		@bestHand = {:handRank => 99, :cardRank => 0, :rankTxt => ''}

	end

	def updateBestHand(pokerRank, cardRank)
		if @bestHand[:handRank] > @pokerRanking[pokerRank]
			@bestHand.merge!({:handRank => @pokerRanking[pokerRank],
				:cardRank => cardRank, :rankTxt => pokerRank})
		elsif @bestHand[:handRank] == @pokerRanking[pokerRank] &&
		      @bestHand[:cardRank] < cardRank
			@bestHand[:cardRank] = cardRank
		end
	end
