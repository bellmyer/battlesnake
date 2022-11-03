require 'json'

describe Battlesnake::Location do
  let(:klass) { Battlesnake::Location }
  let(:object) { klass.new(coords) }

  let(:coords) { {'x' => x, 'y' => y} }
  let(:x) { 5 }
  let(:y) { 6 }

  describe '#initialize' do
    subject { object }

    def self.sets_x_and_y
      it 'sets x' do
        expect(subject.x).to eq(x)
      end

      it 'sets y' do
        expect(subject.y).to eq(y)
      end
    end

    describe 'when coords are a hash' do
      let(:coords) { {'x' => x, 'y' => y} }
      sets_x_and_y
    end

    describe 'when coords are json' do
      let(:coords) { {'x' => x, 'y' => y}.to_json }
      sets_x_and_y
    end

    describe 'when coords are array' do
      let(:coords) { [x, y] }
      sets_x_and_y
    end

    describe 'when coords are passed as multiple parameters' do
      let(:object) { klass.new(x, y) }
      sets_x_and_y
    end
  end
end