class Player
    ABC = Set.new("a".."z")
    
    def initialize(playerIx)
        @label = playerIx
    end

    attr_reader :label

    def make_guess
        valid = false
        until valid
            puts "\nEnter a letter:"
            input = gets.chomp
            if input.length == 1 && ABC.include?(input.downcase)
                guess = input
                valid = true
            else
                puts "Invalid input, please try again."
            end
        end
        guess
    end
end