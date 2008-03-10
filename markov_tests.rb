require 'markov'
require 'test/unit'

class TestMarkov < Test::Unit::TestCase
    SIMPLE_TEXT = "foo bar baz boo foo baz bar boo"
    SIMPLE_TEXT_WORDS = SIMPLE_TEXT.scan(/ /)
     
    def setup
        @markov = Markov.new(2)
    end

    def test_learn_empty_text
        @markov.learn("")
    end

    def test_learn_simple_text
        @markov.learn(SIMPLE_TEXT)
    end

    def test_generate_simple_text
        @markov.learn(SIMPLE_TEXT)

        string = @markov.generate

        # Make sure the resulting words appear in the list of possible words
        string.scan(/ /).each do |word|
            assert_equal(true, SIMPLE_TEXT_WORDS.include?(word))
        end
    end

    def test_known_answer
        #Train the generator with the test input, and compare the resulting states with
        #those produced by a known-good reference implementation
        @markov.learn(KNOWN_ANSWER_TEST_INPUT)

        testStates = @markov.get_states

        dumpStates(testStates, 0)

        KNOWN_ANSWER_STATES.each_key do |word1| 
            known_good_word1_states = KNOWN_ANSWER_STATES[word1]

            assert_equal(true, 
                testStates.include?(word1),
                "The state table is missing first-level word '#{word1}'")

            test_word1_states = testStates[word1]

            known_good_word1_states.each_key do |word2|
                assert_equal(true,
                    test_word1_states.include?(word2),
                    "The state table for first-level word '#{word1}' is missing second-level word '#{word2}'")

                known_good_word2_words = known_good_word1_states[word2]
                test_word2_words = test_word1_states[word2]

                known_good_word2_words.each do |word3|
                    assert_equal(true,
                        test_word2_words.include?(word3),
                        "The word list for tuble '#{word1}, #{word2}' is missing word '#{word3}'")
                end

                diff = known_good_word2_words - test_word2_words

                assert_equal(0,
                    diff.length,
                    "The state table for the word pair ('#{word1}','#{word2}') doesn't match.  Should be [#{known_good_word2_words.join(',')}]; actually is [#{test_word2_words.join(',')}]")
            end
        end

        assert_equal(KNOWN_ANSWER_STATES.length,
            testStates.length,
            "The state table's size differs from the known correct table")
    end

    def dumpStates(states, indentLevel)
        indent = " " * (indentLevel * 2)

        if states.kind_of?(Array)
            states.each do |value|
                puts "#{indent}#{value}"
            end
        else
            states.each_pair do |key, value|
                puts "#{indent}#{key}:"
                dumpStates(value, indentLevel + 1)
            end
        end
    end

    # The input into the known-good markov text generation reference implementation, used to
    # produce the known-good state table
    #
    # Known answers produced with markov.pl, from Kernigan and Pike's 'Practice of Programming', heavily modified
    # to print state table to stdout and use "####" as the non-word indicator
    # 
    # Text excerpted from http://www.gutenberg.org/dirs/etext04/hwswc10h.htm#CHAPTER_I
    KNOWN_ANSWER_TEST_INPUT = <<END_OF_STRING
It is very easy to learn how to speak and write correctly, as for all purposes of ordinary conversation and communication, only about 2,000 different words are required. The mastery of just twenty hundred words, the knowing where to place them, will make us not masters of the English language, but masters of correct speaking and writing. Small number, you will say, compared with what is in the dictionary! But nobody ever uses all the words in the dictionary or could use them did he live to be the age of Methuselah, and there is no necessity for using them.

There are upwards of 200,000 words in the recent editions of the large dictionaries, but the one-hundredth part of this number will suffice for all your wants. Of course you may think not, and you may not be content to call things by their common names; you may be ambitious to show superiority over others and display your learning or, rather, your pedantry and lack of learning. For instance, you may not want to call a spade a spade. You may prefer to call it a spatulous device for abrading the surface of the soil. Better, however, to stick to the old familiar, simple name that your grandfather called it. It has stood the test of time, and old friends are always good friends.

To use a big word or a foreign word when a small one and a familiar one will answer the same purpose, is a sign of ignorance. Great scholars and writers and polite speakers use simple words.
END_OF_STRING

    KNOWN_ANSWER_STATES = {
    	'####' => {
    		'####' => ['It'],
    		'It' => ['is']
    	},
    	'2,000' => {
    		'different' => ['words']
    	},
    	'200,000' => {
    		'words' => ['in']
    	},
    	'Better,' => {
    		'however,' => ['to']
    	},
    	'But' => {
    		'nobody' => ['ever']
    	},
    	'English' => {
    		'language,' => ['but']
    	},
    	'For' => {
    		'instance,' => ['you']
    	},
    	'Great' => {
    		'scholars' => ['and']
    	},
    	'It' => {
    		'has' => ['stood'],
    		'is' => ['very']
    	},
    	'Methuselah,' => {
    		'and' => ['there']
    	},
    	'Of' => {
    		'course' => ['you']
    	},
    	'Small' => {
    		'number,' => ['you']
    	},
    	'The' => {
    		'mastery' => ['of']
    	},
    	'There' => {
    		'are' => ['upwards']
    	},
    	'To' => {
    		'use' => ['a']
    	},
    	'You' => {
    		'may' => ['prefer']
    	},
    	'a' => {
    		'big' => ['word'],
    		'familiar' => ['one'],
    		'foreign' => ['word'],
    		'sign' => ['of'],
    		'small' => ['one'],
    		'spade' => ['a'],
    		'spade.' => ['You'],
    		'spatulous' => ['device']
    	},
    	'about' => {
    		'2,000' => ['different']
    	},
    	'abrading' => {
    		'the' => ['surface']
    	},
    	'age' => {
    		'of' => ['Methuselah,']
    	},
    	'all' => {
    		'purposes' => ['of'],
    		'the' => ['words'],
    		'your' => ['wants.']
    	},
    	'always' => {
    		'good' => ['friends.']
    	},
    	'ambitious' => {
    		'to' => ['show']
    	},
    	'and' => {
    		'a' => ['familiar'],
    		'communication,' => ['only'],
    		'display' => ['your'],
    		'lack' => ['of'],
    		'old' => ['friends'],
    		'polite' => ['speakers'],
    		'there' => ['is'],
    		'write' => ['correctly,'],
    		'writers' => ['and'],
    		'writing.' => ['Small'],
    		'you' => ['may']
    	},
    	'answer' => {
    		'the' => ['same']
    	},
    	'are' => {
    		'always' => ['good'],
    		'required.' => ['The'],
    		'upwards' => ['of']
    	},
    	'as' => {
    		'for' => ['all']
    	},
    	'be' => {
    		'ambitious' => ['to'],
    		'content' => ['to'],
    		'the' => ['age']
    	},
    	'big' => {
    		'word' => ['or']
    	},
    	'but' => {
    		'masters' => ['of'],
    		'the' => ['one-hundredth']
    	},
    	'by' => {
    		'their' => ['common']
    	},
    	'call' => {
    		'a' => ['spade'],
    		'it' => ['a'],
    		'things' => ['by']
    	},
    	'called' => {
    		'it.' => ['It']
    	},
    	'common' => {
    		'names;' => ['you']
    	},
    	'communication,' => {
    		'only' => ['about']
    	},
    	'compared' => {
    		'with' => ['what']
    	},
    	'content' => {
    		'to' => ['call']
    	},
    	'conversation' => {
    		'and' => ['communication,']
    	},
    	'correct' => {
    		'speaking' => ['and']
    	},
    	'correctly,' => {
    		'as' => ['for']
    	},
    	'could' => {
    		'use' => ['them']
    	},
    	'course' => {
    		'you' => ['may']
    	},
    	'device' => {
    		'for' => ['abrading']
    	},
    	'dictionaries,' => {
    		'but' => ['the']
    	},
    	'dictionary' => {
    		'or' => ['could']
    	},
    	'dictionary!' => {
    		'But' => ['nobody']
    	},
    	'did' => {
    		'he' => ['live']
    	},
    	'different' => {
    		'words' => ['are']
    	},
    	'display' => {
    		'your' => ['learning']
    	},
    	'easy' => {
    		'to' => ['learn']
    	},
    	'editions' => {
    		'of' => ['the']
    	},
    	'ever' => {
    		'uses' => ['all']
    	},
    	'familiar' => {
    		'one' => ['will']
    	},
    	'familiar,' => {
    		'simple' => ['name']
    	},
    	'for' => {
    		'abrading' => ['the'],
    		'all' => ['purposes', 'your'],
    		'using' => ['them.']
    	},
    	'foreign' => {
    		'word' => ['when']
    	},
    	'friends' => {
    		'are' => ['always']
    	},
    	'friends.' => {
    		'To' => ['use']
    	},
    	'good' => {
    		'friends.' => ['To']
    	},
    	'grandfather' => {
    		'called' => ['it.']
    	},
    	'has' => {
    		'stood' => ['the']
    	},
    	'he' => {
    		'live' => ['to']
    	},
    	'how' => {
    		'to' => ['speak']
    	},
    	'however,' => {
    		'to' => ['stick']
    	},
    	'hundred' => {
    		'words,' => ['the']
    	},
    	'ignorance.' => {
    		'Great' => ['scholars']
    	},
    	'in' => {
    		'the' => ['dictionary!', 'dictionary', 'recent']
    	},
    	'instance,' => {
    		'you' => ['may']
    	},
    	'is' => {
    		'a' => ['sign'],
    		'in' => ['the'],
    		'no' => ['necessity'],
    		'very' => ['easy']
    	},
    	'it' => {
    		'a' => ['spatulous']
    	},
    	'it.' => {
    		'It' => ['has']
    	},
    	'just' => {
    		'twenty' => ['hundred']
    	},
    	'knowing' => {
    		'where' => ['to']
    	},
    	'lack' => {
    		'of' => ['learning.']
    	},
    	'language,' => {
    		'but' => ['masters']
    	},
    	'large' => {
    		'dictionaries,' => ['but']
    	},
    	'learn' => {
    		'how' => ['to']
    	},
    	'learning' => {
    		'or,' => ['rather,']
    	},
    	'learning.' => {
    		'For' => ['instance,']
    	},
    	'live' => {
    		'to' => ['be']
    	},
    	'make' => {
    		'us' => ['not']
    	},
    	'masters' => {
    		'of' => ['the', 'correct']
    	},
    	'mastery' => {
    		'of' => ['just']
    	},
    	'may' => {
    		'be' => ['ambitious'],
    		'not' => ['be', 'want'],
    		'prefer' => ['to'],
    		'think' => ['not,']
    	},
    	'name' => {
    		'that' => ['your']
    	},
    	'names;' => {
    		'you' => ['may']
    	},
    	'necessity' => {
    		'for' => ['using']
    	},
    	'no' => {
    		'necessity' => ['for']
    	},
    	'nobody' => {
    		'ever' => ['uses']
    	},
    	'not' => {
    		'be' => ['content'],
    		'masters' => ['of'],
    		'want' => ['to']
    	},
    	'not,' => {
    		'and' => ['you']
    	},
    	'number' => {
    		'will' => ['suffice']
    	},
    	'number,' => {
    		'you' => ['will']
    	},
    	'of' => {
    		'200,000' => ['words'],
    		'Methuselah,' => ['and'],
    		'correct' => ['speaking'],
    		'ignorance.' => ['Great'],
    		'just' => ['twenty'],
    		'learning.' => ['For'],
    		'ordinary' => ['conversation'],
    		'the' => ['English', 'large', 'soil.'],
    		'this' => ['number'],
    		'time,' => ['and']
    	},
    	'old' => {
    		'familiar,' => ['simple'],
    		'friends' => ['are']
    	},
    	'one' => {
    		'and' => ['a'],
    		'will' => ['answer']
    	},
    	'one-hundredth' => {
    		'part' => ['of']
    	},
    	'only' => {
    		'about' => ['2,000']
    	},
    	'or' => {
    		'a' => ['foreign'],
    		'could' => ['use']
    	},
    	'or,' => {
    		'rather,' => ['your']
    	},
    	'ordinary' => {
    		'conversation' => ['and']
    	},
    	'others' => {
    		'and' => ['display']
    	},
    	'over' => {
    		'others' => ['and']
    	},
    	'part' => {
    		'of' => ['this']
    	},
    	'pedantry' => {
    		'and' => ['lack']
    	},
    	'place' => {
    		'them,' => ['will']
    	},
    	'polite' => {
    		'speakers' => ['use']
    	},
    	'prefer' => {
    		'to' => ['call']
    	},
    	'purpose,' => {
    		'is' => ['a']
    	},
    	'purposes' => {
    		'of' => ['ordinary']
    	},
    	'rather,' => {
    		'your' => ['pedantry']
    	},
    	'recent' => {
    		'editions' => ['of']
    	},
    	'required.' => {
    		'The' => ['mastery']
    	},
    	'same' => {
    		'purpose,' => ['is']
    	},
    	'say,' => {
    		'compared' => ['with']
    	},
    	'scholars' => {
    		'and' => ['writers']
    	},
    	'show' => {
    		'superiority' => ['over']
    	},
    	'sign' => {
    		'of' => ['ignorance.']
    	},
    	'simple' => {
    		'name' => ['that'],
    		'words.' => ['####']
    	},
    	'small' => {
    		'one' => ['and']
    	},
    	'soil.' => {
    		'Better,' => ['however,']
    	},
    	'spade' => {
    		'a' => ['spade.']
    	},
    	'spade.' => {
    		'You' => ['may']
    	},
    	'spatulous' => {
    		'device' => ['for']
    	},
    	'speak' => {
    		'and' => ['write']
    	},
    	'speakers' => {
    		'use' => ['simple']
    	},
    	'speaking' => {
    		'and' => ['writing.']
    	},
    	'stick' => {
    		'to' => ['the']
    	},
    	'stood' => {
    		'the' => ['test']
    	},
    	'suffice' => {
    		'for' => ['all']
    	},
    	'superiority' => {
    		'over' => ['others']
    	},
    	'surface' => {
    		'of' => ['the']
    	},
    	'test' => {
    		'of' => ['time,']
    	},
    	'that' => {
    		'your' => ['grandfather']
    	},
    	'the' => {
    		'English' => ['language,'],
    		'age' => ['of'],
    		'dictionary' => ['or'],
    		'dictionary!' => ['But'],
    		'knowing' => ['where'],
    		'large' => ['dictionaries,'],
    		'old' => ['familiar,'],
    		'one-hundredth' => ['part'],
    		'recent' => ['editions'],
    		'same' => ['purpose,'],
    		'soil.' => ['Better,'],
    		'surface' => ['of'],
    		'test' => ['of'],
    		'words' => ['in']
    	},
    	'their' => {
    		'common' => ['names;']
    	},
    	'them' => {
    		'did' => ['he']
    	},
    	'them,' => {
    		'will' => ['make']
    	},
    	'them.' => {
    		'There' => ['are']
    	},
    	'there' => {
    		'is' => ['no']
    	},
    	'things' => {
    		'by' => ['their']
    	},
    	'think' => {
    		'not,' => ['and']
    	},
    	'this' => {
    		'number' => ['will']
    	},
    	'time,' => {
    		'and' => ['old']
    	},
    	'to' => {
    		'be' => ['the'],
    		'call' => ['things', 'a', 'it'],
    		'learn' => ['how'],
    		'place' => ['them,'],
    		'show' => ['superiority'],
    		'speak' => ['and'],
    		'stick' => ['to'],
    		'the' => ['old']
    	},
    	'twenty' => {
    		'hundred' => ['words,']
    	},
    	'upwards' => {
    		'of' => ['200,000']
    	},
    	'us' => {
    		'not' => ['masters']
    	},
    	'use' => {
    		'a' => ['big'],
    		'simple' => ['words.'],
    		'them' => ['did']
    	},
    	'uses' => {
    		'all' => ['the']
    	},
    	'using' => {
    		'them.' => ['There']
    	},
    	'very' => {
    		'easy' => ['to']
    	},
    	'want' => {
    		'to' => ['call']
    	},
    	'wants.' => {
    		'Of' => ['course']
    	},
    	'what' => {
    		'is' => ['in']
    	},
    	'when' => {
    		'a' => ['small']
    	},
    	'where' => {
    		'to' => ['place']
    	},
    	'will' => {
    		'answer' => ['the'],
    		'make' => ['us'],
    		'say,' => ['compared'],
    		'suffice' => ['for']
    	},
    	'with' => {
    		'what' => ['is']
    	},
    	'word' => {
    		'or' => ['a'],
    		'when' => ['a']
    	},
    	'words' => {
    		'are' => ['required.'],
    		'in' => ['the', 'the']
    	},
    	'words,' => {
    		'the' => ['knowing']
    	},
    	'write' => {
    		'correctly,' => ['as']
    	},
    	'writers' => {
    		'and' => ['polite']
    	},
    	'writing.' => {
    		'Small' => ['number,']
    	},
    	'you' => {
    		'may' => ['think', 'not', 'be', 'not'],
    		'will' => ['say,']
    	},
    	'your' => {
    		'grandfather' => ['called'],
    		'learning' => ['or,'],
    		'pedantry' => ['and'],
    		'wants.' => ['Of']
    	}
    }
            

end

