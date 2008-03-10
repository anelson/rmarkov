require 'markov'
require 'tokenizer'

include Tokenizer

corpus = 'corpus/'

MARKOV_CHAIN_ORDER = 2

markov = Markov.new(MARKOV_CHAIN_ORDER)

def tokenize_chars(word)
    chars = []
    word.strip.scan(/[[:alnum:]]/) do |char|
        chars << char
    end

    chars
end

Dir.foreach(corpus) do |file|
    path = corpus + '/' + file

    if File.file?(path) && File.extname(path) == ".txt"
        puts "Learning from corpus file '#{path}'"
        
        File.open(path, 'r') do |file|
            file.each_line('') do |paragraph|
                sentences = paragraph.split(/\.\w*/)
        
                sentences.each do |sentence|
                    words = Tokenizer.tokenize(sentence.strip)
                    #words.each do |word|
                        #chars = tokenize_chars(word)
                        chars = tokenize_chars(sentence)

                        #puts "Learning '#{word}'"
                        markov.learn(words)
                    #end
                end
                #markov.learn(Tokenizer.tokenize(paragraph.strip))
            end
        end

        puts "After learning file '#{path}', average entropy per term is #{markov.get_average_entropy_per_term}"
    end
end


#puts "Saving chains to file"
#markov.save(corpus + 'chains.markov')

#puts "Saving graph to file"
#File.open(corpus_file + '.dot', 'w') do |file|
#    markov.save_graph(file)
#end

puts "Average entropy per term is #{markov.get_average_entropy_per_term}"

# Generate a handful of passphrases of at least 128 bits of entropy

10.times do 
    total_entropy = 0.0

    while total_entropy < 128.0
        sentence = markov.generate
        entropies = markov.measure_entropy_for_tokens(sentence)

        sentence_entropy = 0.0
        entropies.each do |entropy|
            sentence_entropy += entropy
        end
    
        print sentence.join(' ')
        print "\t(#{sentence_entropy} bits) "
        puts

        total_entropy += sentence_entropy
    end

    puts " Total entropy #{total_entropy} bits"
    puts

end

    
