require 'markov'
require 'tokenizer'

include Tokenizer

corpus = 'corpus/'

MARKOV_CHAIN_ORDER = 2


markov = Markov.new(MARKOV_CHAIN_ORDER)

Dir.foreach(corpus) do |file|
    path = corpus + '/' + file

    if File.file?(path) && File.extname(path) == ".txt"
        puts "Learning from corpus file '#{path}'"
        
        File.open(path, 'r') do |file|
            file.each_line('') do |paragraph|
                sentences = paragraph.split(/\.\w*/)
        
                sentences.each do |sentence|
                    markov.learn(Tokenizer.tokenize(sentence.strip))
                end
                #markov.learn(Tokenizer.tokenize(paragraph.strip))
            end
        end
    end
end


puts "Saving chains to file"

markov.save(corpus + 'chains.markov')

#puts "Saving graph to file"
#File.open(corpus_file + '.dot', 'w') do |file|
#    markov.save_graph(file)
#end

puts "Average entropy per term is #{markov.get_average_entropy_per_term}"

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

    
