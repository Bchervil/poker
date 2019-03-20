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
def hasStraight
		lowestCard = @handAnalysis.find_index(1)
		if !lowestCard.nil?
			nextFiveCards = @handAnalysis[lowestCard..(lowestCard+4)]
			if nextFiveCards.find_index(0).nil?
				updateBestHand('Straight', 13 - @handAnalysis.reverse.find_index(1))
				true
			else
				false
			end
		else
			false
		end
	end

	def hasFlush
		if @suitAnalysis.has_value?(5)
			highestCard = 0
			@handAnalysis.each_with_index do |cardCount,i|
				highestCard = i+1 if cardCount == 1 #must be 1
			end
			updateBestHand('Flush', highestCard)
			true
		else
			false
		end
	end

	def hasStraightFlush
		if @hand.size == 5
			flush = hasFlush
			straight = hasStraight
			if flush && straight
				if @handAnalysis.last == 1
					updateBestHand('Royal Flush', 13)
				else
					updateBestHand('Straight Flush', 13 - @handAnalysis.reverse.find_index(1))
				end
			end
		end
	end

	def hasMultiples
		#Single, Pairs, Trips and Quads
		hasPair = false, hasTrips = false, tripsCardRank = 0
		@handAnalysis.each_with_index do |cardCount,i|
			case cardCount
			when 1
				updateBestHand('High Card', i+1)
			when 2
				if hasPair == true
					updateBestHand('Two Pairs', i+1)
				else
					updateBestHand('Pair', i+1)
					hasPair = true
				end
			when 3
				updateBestHand('Triples', i+1)
				hasTrips = true
				tripsCardRank = i+1
			when 4
				updateBestHand('Four of a Kind', i+1)
			end
		end
		#Full House
		updateBestHand('Full House', tripsCardRank) if hasPair == true && hasTrips == true
	end

	def analyseHand
		# check for straight or flush
		hasStraightFlush
		# check for face value groups
		hasMultiples
	end

public
	def addCard(deck)
		@hand << deck.drawCard
		@handAnalysis[@hand.last.rank-1] += 1
		@suitAnalysis[@hand.last.suit] += 1
		analyseHand
		@hand.last.show
	end

	def showBestHand
		@bestHand[:rankTxt].upcase
	end

end

# Fivecard Class
class Fivecard
	def initialize
		@deck = Deck.new
		@human = Hand.new
		@computer = Hand.new
		@humanMoney = 200
		@computerMoney = 200
		@currentBet = 0
	end

	def newHand
		@deck.shuffle
		@human = Hand.new
		@computer = Hand.new
		@currentBet = 0
	end

	def noOneBrokeYet?
		@humanMoney > 0 && @computerMoney > 0
	end

	

	def dealCards(n)
		n.times do
			print(@human.addCard(@deck).ljust(16), @computer.addCard(@deck), "\n")
		end
	end

	def makeBet
		goodBet = false
		lowestMoney = [@humanMoney,@computerMoney].min
		while goodBet == false
			print("Bet ?")
			amount = gets.chomp.to_i
			if amount < 1
				puts "Huh?"
			elsif amount > 20
				puts "House limit is $20"
			elsif lowestMoney < amount
				puts "The limit is now only $" << lowestMoney.to_s
			else
				goodBet = true
			end
		end
		@currentBet = amount
	end

	def findWinner
		humanWins = false, computerWins = false, tie = false
		if @human.bestHand[:handRank] < @computer.bestHand[:handRank]
			humanWins = true
		elsif @human.bestHand[:handRank] > @computer.bestHand[:handRank]
			computerWins = true
		else
			#must be tie, check card rank
			if @human.bestHand[:cardRank] > @computer.bestHand[:cardRank]
				humanWins = true
			elsif @human.bestHand[:cardRank] < @computer.bestHand[:cardRank]
				computerWins = true
			else
				tie = true
			end
		end
		print(@human.showBestHand.ljust(16), @computer.showBestHand, "\n")
		case true
		when humanWins
			puts ("     You win $" + @currentBet.to_s)
			@humanMoney += @currentBet
			@computerMoney -= @currentBet
		when computerWins
			puts ("     I win $" + @currentBet.to_s)
			@humanMoney -= @currentBet
			@computerMoney += @currentBet
		when tie
			puts "     Tie Hand".
		end
		print(("You = $" + @humanMoney.to_s).ljust(16).("Me = $" + @computerMoney.to_s), "\n\n")
	end

	def result
		puts
		if @humanMoney == 400
			puts "I'm Busted... You Win!!!"
		else
			puts "You're Broke... I Win!!!"
		end
	end

end

# Play Game at its basic form
game = Fivecard.new


while game.noOneBrokeYet?
	game.newHand
	game.dealCards(2)
	game.makeBet
	game.dealCards(3)
	game.findWinner
end
end
game.result
