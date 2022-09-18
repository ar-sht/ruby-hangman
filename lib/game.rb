# frozen_string_literal: true
require 'colorize'

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
  end

  def play
    p @answer
    until over?
      guess
      display
    end
    if lost?
      puts "#{"\nHaha, you lost. The word was ".colorize(:white)}#{@answer.colorize(:magenta)}"
    else
      puts "#{"\nCongrats, you won in ".colorize(:white)}#{@guessed.size.to_s.colorize(:magenta)}#{' turns'
                                                                                                     .colorize(:white)}"
    end
  end

  private

  def over?
    @wrong_guesses.length > 6 || @to_display == @answer.split(//)
  end

  def lost?
    @wrong_guesses.length > 6
  end

  def guess
    puts "\nPlease enter your guess:".colorize(:white)
    @guess = gets.chomp.downcase.strip
    until @guess.length == 1 && (@guess.ord >= 97 && @guess.ord <= 122) && !@guessed.include?(@guess)
      puts 'Invalid Input. Please enter a new letter:'.colorize(:white)
      @guess = gets.chomp.downcase.strip
    end
  end

  def display
    check_guess
    unless over?
      puts "#{"\nWrong guesses: ".colorize(:white)}#{"#{@wrong_guesses.size} out of 7".colorize(:light_cyan)}"
      puts "#{'Already guessed: '.colorize(:white)}#{@guessed.join(', ').colorize(:light_cyan)}" unless @guessed.empty?
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
end

game = Game.new
game.play
