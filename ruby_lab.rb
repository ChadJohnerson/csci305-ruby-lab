
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Chad Johnerson
# chad.johnerson@ecat.montana.edu
#
###############################################################

$bigrams = Hash.new { |bigrams, k| bigrams[k] = {} } # The Bigram data structure
$name = "Chad Johnerson"

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		count = 0
		wordsArray = []
		IO.foreach(file_name, encoding: "UTF-8") do |line|
			# do something for each line
			song = cleanup_title(line) #clean up each line that we are reading from the file
			if song.nil? == false #checks to make sure we have a song to split on that isnt nil.
				count = count + 1
				wordsArray = song.split(" ")
			end

			if wordsArray.count > 1
				wordsArray.each_cons(2) do |word, nextword|
					if $bigrams.has_key?("#{word}") #checks to see if the key already exists
						if $bigrams["#{word}"].has_key?("#{nextword}") # checks to see if the key that exists has a word already as a word that follows the previous word
							$bigrams["#{word}"]["#{nextword}"] = $bigrams["#{word}"]["#{nextword}"] + 1 #add one to the count of the word that follows the key word
						else
							$bigrams["#{word}"]["#{nextword}"] = 0 #create the word that follows the key word and give it a count of 0, initializing it.
						end
					else
						$bigrams["#{word}"]["#{nextword}"] = 0 #The word key didn't exist, create it and put its nextword there as its a first occurrence
					end
				end
			end
		end
		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

def cleanup_title(line)
	line =~ /([^>]*)$/ #matches on the last occurrence of '>' and only grabs the characters after it
	title1 = $1
	superfluousCleanTitles = title1.gsub(/\(.*|\[.*|\{.*|\\.*|\/.*|\_.*|\-.*|\:.*|\".*|\`.*|\+.*|\=.*|\*.*|feat\..*/, '') #matches on the first occurrence of character and replaces everything after with a blank character
	cleanTitles = superfluousCleanTitles.gsub(/\?|\¿|\!|\¡|\.|\;|\&|\@|\%|\#|\|/, '') #remove all punctuation marks and replace with blank characters
	if cleanTitles =~ /^[\d\w\s']+$/ #return only english characters. this excludes all of the non english song titles
		title = cleanTitles.downcase.gsub(/a\W|an\W|and\W|by\W|for\W|from\W|in\W|of\W|on\W|or\W|out\W|the\W|to\W|with\W/, '') #left this with the given stop characters in order to pass the thrid test. Fix is not implimented.
	end
	return title
end

#pass this a word to find what the most common word that follows it will be
def mcw(word)
	mostCommon = $bigrams["#{word}"].sort_by {|word, count| count}.last #sort the bigram smalles to largest and take the last value (should be largest)
	potentialWords = [] #in the case that there are multiple words with the same count as current mostCommon
	$bigrams["#{word}"].each do |nextword, count| #loop through all possible words that follow the word in question
		if count == mostCommon[1] #logic to see if a word in the bigram has a count equal to mostCommon
			 potentialWords.push(nextword) #push this word/count to the array
		end
	end
	mostCommon = potentialWords.sample #randomly select a most common word from array that has all of the potential words
	#puts "The most common word that follows '#{word}' is '#{mostCommon}'"
	return "#{mostCommon}"
end

#creates a title based of the most common word following the previous word
def create_title(word)
	wordcount = 1 #set to 1 initially due to the first word passed in
	nextword = mcw(word)
	title = "#{word}"
	while wordcount < 20 || nextword == nil
		title = "#{title} #{nextword}" #build the title every iteration
		wordcount = wordcount + 1 #keep track of the count to break the while if need be
		nextword = mcw(nextword) #call mcw on next word
	end
	#uncomment to print title out.
	#puts "#{title}".strip
	return "#{title}".strip #returns a string of 20 words, strips spaces
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	user_in = ''
	while user_in != 'q'
		puts "Enter a word [Enter 'q' to quit]:"
		user_in = STDIN.gets.chomp.downcase
		if user_in =='q'
			exit
		end
		create_title("#{user_in}")
	end
end

if __FILE__==$0
	main_loop()
end
