require "set"
require_relative "1_player"
require_relative "2_ai_player"

class GhostGame
    MAX_LOSS_COUNT = 5

    def initialize(num_players, num_ai)
        @players = []
        num_players.times { |i| @players << Player.new("Player #{i + 1}") }
        num_ai.times { |i| @players << AiPlayer.new("AI #{i + 1}") }
        @fragment = ""
        @player_losses = {}
        @players.each { |player| @player_losses[player] = 0 }
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
            puts "\n#{self.previous_player.label}'s guess was valid! #{self.current_player.label} loses!"
            return player_lose(self.current_player)
        else
            puts "\n#{self.previous_player.label}'s guess was invalid! They lose!"
            return player_lose(self.previous_player)
        end
    end

    def player_lose(player)
        puts "MUAHAHA, you lose #{player.label}!"
        @player_losses[player] += 1
        true
    end

    def take_turn
        player = self.current_player
        puts "#{player.label}'s turn"
        puts "Fragment is: #{@fragment}" if @fragment.length > 0

        if @fragment.length != 0
            puts "\nChallenge the previous player? y/n"
            challenge = gets.chomp.downcase == "y"
        end

        if challenge
            return self.challenge_previous
        else
            guess = player.make_guess
            @fragment += guess
            puts "The fragment now is: #{@fragment}"
        end

        if self.player_lose_round?
            puts "\n#{player.label} loses! The word exists!"
            return self.player_lose(player)
        end
        puts "\n-".ljust(60, "-")

        self.next_player!
        false
    end

    def player_string(player)
        i = @player_losses[player]
        "GHOST"[0...i]
    end

    def winning_moves
        ("a".."z").to_a
        .reject { |ch| @zdictionary.include?(@fragment + ch) }
        .select { |ch| self.valid_guess?(ch) }
    end

    def take_ai_turn
        player = self.current_player
        puts "#{player.label}'s turn"
        puts "Fragment is: #{@fragment}" if @fragment.length > 0
        puts "\nbeep-boop"

        # If they can kill another player, they will
        if !valid_guess?("")
            puts "\n#{player.label} Challenges!"
            return self.challenge_previous
        end

        # If no available winning moves, they will select a random move
        # p winning_moves
        if !self.winning_moves.empty?
            guess = self.winning_moves.sample
            puts "\n#{player.label} chooses:"
            puts "#{guess}"
        else
            guess = player.ai_make_guess
        end

        @fragment += guess
        puts "The fragment now is: #{@fragment}"
        
        if self.player_lose_round?
            puts "\n#{player.label} loses! The word exists!"
            return self.player_lose(player)
        end
        puts "\n-".ljust(60, "-")

        self.next_player!
        false
    end

    def play_round
        game_over = false
        until game_over
            game_over = self.current_player.is_a?(Player) ? self.take_turn : self.take_ai_turn 
        end
        puts "\n-".ljust(60, "-")

    end

    def play_game
        round_number = 1

        until @players.length == 1
            until @player_losses.values.any? { |losses| losses == MAX_LOSS_COUNT }
                puts "\n#".ljust(60, "#")
                padding = (60 - "ROUND #{round_number}".length) / 2
                puts " ".ljust(padding, " ") + "ROUND #{round_number}"
                puts "-".ljust(60, "-")

                if round_number > 1
                    puts "Current standings:"
                    @player_losses.each_key do |player|
                        puts "#{player.label} - #{self.player_string(player)}"
                    end
                    puts "-".ljust(60, "-")
                end

                self.play_round
                @fragment = ""
                round_number += 1
            end
            loser = @player_losses.invert[5]
            padding = (60 - "#{loser.label} has been eliminated!".length) / 2
            puts "\n ".ljust(padding, " ") + "#{loser.label} has been eliminated!".upcase
            @player_losses[loser] += 1 # To presserve in the hash
            @players.delete(loser)
        end
        
        puts "\n#".ljust(60, "#")
        padding = (60 - "#{self.current_player.label} IS THE CHAMPION!".length) / 2
        puts "\n ".ljust(padding, " ") + "#{self.current_player.label} IS THE CHAMPION!".upcase
        puts
    end
end

if __FILE__ == $PROGRAM_NAME
    puts "#".ljust(60, "#")
    padding = (60 - "LET'S PLAY GHOST!".length) / 2
    puts " ".ljust(padding, " ") + "LET'S PLAY GHOST!"
    puts "#".ljust(60, "#")
    puts "\nEnter the number of human players (press enter or write 0 for none):"
    humanPlayers = gets.chomp.to_i
    puts "\nEnter the number of AI's (press enter or write 0 for none):"
    ais = gets.chomp.to_i
    game = GhostGame.new(humanPlayers, ais)
    game.play_game
end