require 'json'

module Battlesnake
  class Snake
    attr_reader :raw, :id, :name, :body, :latency, :health, :head, :length, :shout, :squad, :customizations

    def initialize(json_or_hash)
      @raw = json_or_hash.is_a?(String) ? JSON.parse(json_or_hash) : json_or_hash

      @id = @raw['id']
      @name = @raw['name']
      @latency = @raw['latency']
      @health = @raw['health']
      @length = @raw['length']
      @shout = @raw['shout']
      @squad = @raw['squad']
      @customizations = @raw['customizations']

      @body = @raw['body'].map{ |coords| Location.new(coords) }
      @head = Location.new(@raw['head'])
    end
  end
end