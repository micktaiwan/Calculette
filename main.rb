#!/usr/bin/env ruby
# :main: README

# =MachineLearning maths
# main program without gui

require 'readline'
require 'brain'

class Calculette

  ProgramVersion = "Calculette - v0.1 - 13-Nov-2011"
  CLIST = [
    'help', 'load'
    ].sort

  def initialize
    puts "Welcome to #{ProgramVersion}\nType 'help' to get... help.\nPress TAB for autocompletion."
    @brain = Brain.new
    ARGV.each do|a|
      @brain.load_file(a)
    end
  end

  def main
    comp = proc { |s| CLIST.grep( /^#{Regexp.escape(s)}/ ) }
    Readline.completion_append_character = ""
    Readline.completion_proc = comp
    begin
      while input = Readline.readline('>', true)
        begin
          case
          when (input=="quit" or input=="exit")
            exit
          when input[0..3]=="help"
            print_help(input[5..-1])
          when input[0..3]=="load"
            @brain.load_file(input[5..-1])
          when input==""
          else
            @brain.execute(input)
          end
        # inner loop
        rescue  Exception=> e
          puts e
          #puts e.backtrace
          puts @brain.parser.error_tree
        end
      end
    # outer loop for readline
    rescue  Interrupt=> e # Ctrl-C
      puts
    rescue  Exception=> e
      puts e
      puts e.backtrace
    end
  end

  def print_help(arg=nil)
    case arg
    when nil
      puts "get more help with 'help keyword':"
      puts "help helpers: Helpers"
      puts "help arith: Standard arithmetic"
    when "helpers"
      puts "Helpers"
      puts "  load <filename>: execute file stored on disk"
    when "arith"
      puts "Standard arithmetic"
      puts "  1+2"
      puts "  b=3"
      puts "  a=4+b"
    else
      puts "Unknown help section"
    end
  end

end

Calculette.new.main

