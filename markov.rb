include Math

class Markov
    NONWORD = "####"

    def initialize(order)
        @words = Hash.new
        @order = order
    end

    def learn(word_list) 
        return if word_list.length <= @order
        #Pad 'words' with the NONWORD char to get things rolling
        @order.times do
            word_list.insert(0, NONWORD)
        end

        #Append with NONWORD to terminate
        word_list << NONWORD

        word_list.each_with_index do |word, index| 
            learn_word(word_list[index - @order, @order + 1]) unless index < @order
        end
    end

    def generate
        #Start by picking a random state starting with NONWORD
        state = generate_initial_state()
        output = []

        #puts "Initial state: #{state.join(',')}"

        output << generate_word(state) while state.length > 0

        return output
    end

    # Measures the entropy of a generated string in terms of Shannon's information theory
    # Returns an array with length identical to tokens.length, where each element is the entropy (in bits)
    # of the value
    def measure_entropy_for_tokens(tokens)
        #Determine the entropy (in bits) of the set of tokens relative to the markov chains
        #by noting the probability that each token would be selected
        return [] if tokens.length == 0

        state = []
        @order.times do
            state << NONWORD
        end

        entropy = []
        tokens.each do |token|
            entropy << measure_entropy_for_state(state)

            # Shift the token into the state, and the left-most state token off the array
            state << token
            state.shift
        end

        entropy
    end

    # Saves the markov chains to a file
    def save(filename)
        state = {
            :order => @order,
            :words => @words
        }

        File.open(filename, 'w') do |file|
            file << @order << $/
            save_tuples @words, file
        end
    end

    # Creates and returns a new Markov object based on chains previously saved
    # with save
    def self.load(filename)
        File.open(filename, 'r') do |file|
            order = file.readline.chomp

            markov = Markov.new(order.to_i)

            markov.load_tuples(file)
    
            markov
        end
    end

    def get_states
        return @words
    end

    def set_states(states)
        @words = states
    end

    def save_tuples(words, file)
        words.each_pair do |key, value|
            save_tuples_prefix key, value, file
        end
    end

    def load_tuples(file)
        words = {}
        file.each_line do |line|
            tuple = line.chomp.split("\t")

            learn_word(tuple)
        end
    end

private
    LOG2 = Math.log(2)

    def measure_entropy_for_state(state)
        if state.length != @order
            raise ArgumentError, "The state vector [#{state.join(',')}] is not the right length; length is #{state.length}, but should be #{@order+1}"
        end

        # For each dimension of the state vector, note the probability of the vector's value being selected over alterate values
        # Per shannon, information entropy (http://en.wikipedia.org/wiki/Information_entropy) for a variable X with n possible values
        # [X0,X1,...,Xn], where each possible value Xi has probability P(Xi), the entropy (in bits) of the variable is H(X):
        #
        # H(x) = -SUM(0..n P(Xi) * log2(P(Xi))
        #
        # For the words in the markov chain, the probability of each possible word in each link of the chain is equal, so
        # the P(Xi) for any Xi is 1/N where N is the number of possible words.  For the last word in the state, which is selected
        # from an array which may contain multiple occurrances of the same word, the probability P(Xi) will be potentialy different
        # for different values of i, hence the more complicated logic to compute this final entropy value

        # Determine the entropy of the last word in 'state', which is the one picked out of an array of possible values            
        current_word = @words
        state.each do |state_word|
            if !current_word.include?(state_word)
                raise ArgumentError, "The state vector [#{state.join(',')}] was not generated from the current Markov chains"
            end
            current_word = current_word[state_word]
        end

        #current_word is the array of possible next states.  The array, unlike the hash, may contain
        #duplicate values, so count the number of occurrences of the value in the state vector
        #
        # build a hash consisting of each unique word in the array as the key, and the 
        # number of times that word appears in the array as the value.  From this, the P(Xi) 
        # function can be determined
        unique_words = {}
        current_word.each do |word|
            unique_words[word] ||= 0
            unique_words[word] += 1
        end

        #Now that occurrence counts are known, convert them to probabilities
        # Compute sum[p(xi) * log2(p(xi))] for all x to get the entropy
        # Ruby doesn't have a log2 function, so take advantage of log properties
        # that log2(x) = logn(x) / logn(2)
        entropy = 0.0
        unique_words.each_pair do |key, value|
            prob = value.to_f / current_word.length.to_f

            entropy += prob * Math.log(prob) / LOG2
        end

        entropy = -entropy

        #puts "Computed entropy #{entropy} for state [#{state.join(',')}]"

        entropy
    end

    def save_tuples_prefix(prefix, words, file)
        if words.kind_of?(Array)
            words.each do |word|
                file << prefix << "\t" << word << $/
            end
        else
            words.each_pair do |word, next_words|
                save_tuples_prefix(prefix + "\t" + word, next_words, file)
            end
        end
    end

    def generate_initial_state()
        # Build an array of @order elements, containing a randomly-selected starting sequence.
        state = []

        @order.times do 
            state << NONWORD
        end

        #puts "Seeded state with NONWORD values; priming state with word values"

        #Iterate generate_word @order times to clear the NONWORD values out of 'state' and prime it with
        #actual words
        @order.times do
            generate_word(state)
        end

        #puts "Seeded state: #{state.join(',')}"

        state
    end

    def generate_word(state)
        # State is an array of @order elements reflecting the last @order words generated by the
        # generator.  Shift the array so element 0 falls off and the rest of the elements shift
        # left by once place; the fallen-off element 0 is the next word generated.
        #
        # Append a new word to the end of the array based on the state transition probabilities
        # for the words in the array
        if state.length == @order
            next_word = generate_next_word(state)
    
            # Only add this to the state vector if it's a word value.
            # NONWORD indicates the end of the sequence
            if next_word != NONWORD
                state << next_word
            end
        end

        #puts "Generating word #{state[0]}; state: [#{state.join(',')}]"

        # 'pop' the left-most word off the state and return it
        return state.shift
    end

    def generate_next_word(state)
        # Given an @order-element state, generates another word consistent with the state transition
        # probabilities
        current_word = @words

        if state.length != @order  
            raise ArgumentError, "Word state has an incorrect number of elements, #{state.length} (should be #{@order})", caller
        end

        state.each do |word|
            if !current_word.include?(word)
                raise ArgumentError, "Word state [#{state.join(',')}] isn't a valid tuple"
            end
            current_word = current_word[word]
        end

        # current_word is now an array of possible next works.  Just pick one at random
        word = current_word[rand(current_word.length)]

        #puts "Generated word '#{word}' from state vector [#{state.join(',')}]"

        word
    end

    def learn_word(wordStates)
        #wordStates[wordStates.length-1] is the word to learn; the preceeding word(s) are used to build the Markov chain
        #puts "Learning #{wordStates.join(',')}"

        current_word = @words
        wordStates.each_with_index do |word, index|
            #puts "#{word}"

            if index < @order - 1
                current_word[word] ||= {}
                current_word = current_word[word]
            elsif index == @order - 1
                current_word[word] ||= []
                current_word = current_word[word]
            else
                current_word << word
            end
        end
    end
end
