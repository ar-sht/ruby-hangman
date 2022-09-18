# frozen_string_literal: true

require 'colorize'
require 'yaml'

class Game
  def initialize
    @dictionary = File.readlines('all_words.txt')
                      .map { |line| line.gsub("\n", '') }
                      .select { |word| word.length >= 5 && word.length <= 12 }
    @answer = @dictionary.sample
    @to_display = ['_'] * @answer.length
    @guessed = []
    @guess = ''
    @wrong_guesses = []
    @current_status = {
      answer: @answer,
      to_display: @to_display,
      guessed: @guessed,
      wrong_guesses: @wrong_guesses
    }
    @save_name = ''
    @load_name = ''
  end

  def begin
    puts '1. Start a new game'.colorize(:light_cyan)
    puts '2. Load a saved game'.colorize(:light_cyan)
    puts 'Please select one of the above options'.colorize(:white)
    start = gets.chomp.strip
    until start.ord.between?(49, 50) && start.length == 1
      puts 'Enter 1 or 2:'
      start = gets.chomp.strip
    end
    if start.to_i == 1
      puts 'You\'ve chosen to start a new game...'.colorize(:white)
      sleep(0.250)
      puts 'Random answer selected'.colorize(:white)
    elsif Dir.exist?('saved_games')
      load
      display
    else
      puts 'There are no saved games, just start a new one you lazy butt-hole'.colorize(:red)
      sleep(0.250)
      puts 'Random answer selected'.colorize(:white)
    end
    play
  end

  private

  def over?
    @wrong_guesses.length > 6 || @to_display == @answer.split(//)
  end

  def lost?
    @wrong_guesses.length > 6
  end

  def load
    puts 'Please enter the name of the file you\'d like to open:'.colorize(:white)
    games = Dir.entries('saved_games').select { |f| File.file? File.join('saved_games', f) }
    puts games
      .map { |file| file.gsub('.yaml', '') }
      .join("\n")
      .colorize(:light_cyan)
    Dir.chdir('saved_games')
    @load_name = gets.chomp
    until File.exist?("#{@load_name}.yaml") || @load_name == 'cancel'
      puts "#{@load_name
                .colorize(:magenta)}#{" does not exist, please try again (type 'cancel' if you've changed your mind):"
                                        .colorize(:white)}"
      @load_name = gets.chomp
    end
    if @load_name == 'cancel'
      puts "Ok, starting new game...".colorize(:white)
      Dir.chdir('..')
      return
    end

    loaded_string = File.read("#{@load_name}.yaml")
    loaded_status = YAML.load(loaded_string)
    puts "#{'Saved game '.colorize(:white)}#{@load_name.colorize(:magenta)}#{' loaded'.colorize(:white)}"
    @answer = loaded_status[:answer]
    @to_display = loaded_status[:to_display]
    @guessed = loaded_status[:guessed]
    @wrong_guesses = loaded_status[:wrong_guesses]
    Dir.chdir('..')
  end

  def save
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    puts 'What would you like to save this game as?'.colorize(:white)
    @save_name = gets.chomp
    save_string = YAML.dump(@current_status)
    Dir.chdir('saved_games')
    File.write("#{@save_name}.yaml", save_string)
    puts "#{'Your game has been saved as '.colorize(:white)}#{@save_name.colorize(:magenta)}"
    Dir.chdir('..')
  end

  def input
    puts "\nPlease enter your guess or type 'save' to save your progress:".colorize(:white)
    @guess = gets.chomp.downcase.strip
    until (@guess.length == 1 && (@guess.ord >= 97 && @guess.ord <= 122) && !@guessed.include?(@guess)) || @guess == 'save'
      puts "Invalid Input. Please enter a letter that hasn't been guessed yet or the word 'save':".colorize(:white)
      @guess = gets.chomp.downcase.strip
    end
    if @guess == 'save'
      save
      exit!
    end
  end

  def display
    check_guess
    unless over?
      puts "#{"\nWrong guesses: ".colorize(:white)}#{"#{@wrong_guesses.size} out of 7".colorize(:light_cyan)}"
      nice_guess_display = @guessed.reduce('') do |str, letter|
        if @wrong_guesses.include?(letter)
          "#{str}#{letter.colorize(:magenta)} "
        else
          "#{str}#{letter.colorize(:light_cyan)} "
        end
      end
      puts "#{'Already guessed: '.colorize(:white)}#{nice_guess_display}" unless @guessed.empty?
    end
    puts @to_display.join(' ').colorize(:light_white)
  end

  def check_guess
    if @answer.include?(@guess)
      @answer.split(//).each_with_index { |letter, index| @to_display[index] = letter if letter == @guess }
    else
      @wrong_guesses << @guess
    end
    @guessed << @guess
  end

  def play
    until over?
      input
      display
    end
    if lost?
      puts "#{"\nHaha, you lost. The word was ".colorize(:white)}#{@answer.colorize(:magenta)}"
    else
      puts "#{"\nCongrats, you won in ".colorize(:white)}#{@guessed.size.to_s.colorize(:magenta)}#{' turns'
                                                                                                     .colorize(:white)}"
    end
  end
end

game = Game.new
game.begin
