require 'json'

describe Battlesnake::Board do
  let(:klass) { Battlesnake::Board }
  let(:object) { klass.new(attribs) }

  let(:attribs) { data }
  let(:json) { data.to_json }
  let(:data) { Fabricate(:board).as_json }

end