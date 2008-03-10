require 'markov'
require 'tokenizer'

include Tokenizer

file = 'corpus/rudyard kipling.txt'

MARKOV_CHAIN_ORDER = 2


markov = Markov.new(MARKOV_CHAIN_ORDER)

File.open(file, 'r') do |file|
    file.each_line('') do |paragraph|
        sentences = paragraph.split(/\.\w*/)

        sentences.each do |sentence|
            markov.learn(Tokenizer.tokenize(sentence.strip))
        end
        #markov.learn(Tokenizer.tokenize(paragraph.strip))
    end
end

markov.save('corpus/rudyard kipling.markov')

10.times do 
    sentence = markov.generate
    entropy = markov.measure_entropy_for_tokens(sentence)

    puts "Generated #{sentence.length} tokens for sentence"

    total_entropy = 0
    sentence.each_with_index do |token, index|
        puts "\t#{token} (#{entropy[index]} bits)"
        total_entropy += entropy[index]
    end

    puts " - Total entropy: #{total_entropy} bits"
    puts

end

    
