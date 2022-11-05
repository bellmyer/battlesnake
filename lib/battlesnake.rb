require "battlesnake/version"
require 'battlesnake/base'
require 'battlesnake/board'
require 'battlesnake/game'
require 'battlesnake/location'
require 'battlesnake/snake'

##
# Primary namespace for the battlesnake gem.
module Battlesnake
  ##
  # Default error class for Battlesnake.
  class Error < StandardError; end
end
