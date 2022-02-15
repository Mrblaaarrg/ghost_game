require_relative "1_player"

class GhostGame
    def initialize(num_players)
        @players = []
        num_players.times { |i| @players << Player.new("Player #{i + 1}") }
        @fragment = ""
        @zdictionary = File.read("dictionary.txt").split.to_set
    end

    def current_player
        @players.first
    end

    def previous_player
        @players.last
    end

    def next_player!
        @players.rotate!
    end

    def valid_guess?(guess)
        checked_fragment = @fragment + guess
        @zdictionary.any? { |word| word.start_with?(checked_fragment) }
    end

    def player_lose_round?
        @zdictionary.include?(@fragment)
    end

    def challenge_previous
        if valid_guess?("")
            puts "#{self.previous_player.label}'s guess was valid! #{self.current_player.label} loses!"
            return false
        else
            puts "#{self.previous_player.label}'s guess was invalid! They lose!"
            return true
        end
    end

    def player_lose(player)
        puts "muahaha you lose #{player.label}"
        true
    end

    def take_turn
        player = self.current_player
        puts "\n-".ljust(60, "-")
        puts "#{player.label}'s turn"
        puts "Fragment is: #{@fragment}"

        if @fragment.length != 0
            puts "\nChallenge the previous player? y/n"
            challenge = gets.chomp.downcase == "y"
        end

        if challenge
            if self.challenge_previous
                return player_lose(self.previous_player)
            else
                return player_lose(player)
            end
        else
            guess = player.make_guess
            @fragment += guess
            puts "The fragment now is: #{@fragment}"
        end

        if self.player_lose_round?
            puts "\n#{player.label} loses! The word exists!"
            return self.player_lose(player)
        end

        self.next_player!
        false
    end

    def play_round
        game_over = false
        until game_over
            game_over = self.take_turn
        end
    end

end