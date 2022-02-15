class AiPlayer
    ABC = ("a".."z").to_a
    
    def initialize(playerIx)
        @label = playerIx
    end

    attr_reader :label

    def ai_make_guess
        guess = ABC.sample
        puts "\n#{@label} chooses:"
        puts "#{guess}"
        guess
    end
end