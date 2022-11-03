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

  describe '#distance(location)' do
    subject { object.distance(other_location) }

    let(:other_location) { klass.new(other_coords) }
    let(:distance) { 2 }

    describe 'when other location is directly right' do
      let(:other_coords) { coords.merge('x' => object.x + distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly left' do
      let(:other_coords) { coords.merge('x' => object.x - distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly up' do
      let(:other_coords) { coords.merge('y' => object.y + distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly down' do
      let(:other_coords) { coords.merge('y' => object.y - distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location differs vertically and horizontally' do
      let(:other_coords) { {'x' => object.x + delta_x, 'y' => object.y + delta_y} }

      let(:distance) { delta_x + delta_y }
      let(:delta_x) { 2 }
      let(:delta_y) { 2 }

      it { is_expected.to eq(distance) }
    end
  end
end