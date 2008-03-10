# Basic tokenizer to extract individual word tokens from English text
module Tokenizer
    def tokenize(sentence)
        # Strip punctuation like () [] {} and "
        sentence.gsub!(/[\(\)\[\]\{\}\"]/, "")

        # Split text into an array of words on whitespace
        words = sentence.split(/\s+/)

        words
    end
end
