require 'json'

describe Battlesnake::Location do
  let(:klass) { Battlesnake::Location }
  let(:object) { klass.new(data) }

  let(:data) { {'x' => x, 'y' => y} }
  let(:x) { 5 }
  let(:y) { 6 }

  it_behaves_like 'model'

  describe '#initialize' do
    subject { object }

    def self.sets_x_and_y
      it 'sets x' do
        expect(subject.x).to eq(x)
      end

      it 'sets y' do
        expect(subject.y).to eq(y)
      end

      it 'sets as_json' do
        expect(subject.as_json).to eq({'x' => object.x, 'y' => object.y})
      end
    end

    describe 'when input is a hash' do
      let(:data) { {'x' => x, 'y' => y} }
      sets_x_and_y
    end

    describe 'when input is json' do
      let(:data) { {'x' => x, 'y' => y}.to_json }
      sets_x_and_y
    end

    describe 'when input is an array' do
      let(:data) { [x, y] }
      sets_x_and_y
    end

    describe 'when input is passed as multiple parameters' do
      let(:object) { klass.new(x, y) }
      sets_x_and_y
    end
  end

  describe '#coords' do
    subject { object.coords }

    it { is_expected.to eq([object.x, object.y]) }

    it 'memoizes the result' do
      expect(object).to receive(:x).once
      expect(object).to receive(:y).once

      2.times { object.coords }
    end
  end

  describe '#distance(location)' do
    subject { object.distance(other_location) }

    let(:other_location) { klass.new(other_coords) }
    let(:distance) { 2 }

    describe 'when other location is directly right' do
      let(:other_coords) { data.merge('x' => object.x + distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly left' do
      let(:other_coords) { data.merge('x' => object.x - distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly up' do
      let(:other_coords) { data.merge('y' => object.y + distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location is directly down' do
      let(:other_coords) { data.merge('y' => object.y - distance) }
      it { is_expected.to eq(distance) }
    end

    describe 'when other location differs vertically and horizontally' do
      let(:other_coords) { {'x' => object.x + delta_x, 'y' => object.y + delta_y} }

      let(:delta_x) { 2 }
      let(:delta_y) { 2 }

      it { is_expected.to eq(delta_x + delta_y) }
    end
  end

  describe '#direction' do
    subject { object.direction(other_location) }

    let(:other_location) { klass.new(other_coords) }
    let(:distance) { 2 }
    let(:further) { distance * 2 }

    describe 'when other location is directly right' do
      let(:other_coords) { data.merge('x' => object.x + distance) }
      it { is_expected.to eq('right') }
    end

    describe 'when other location is directly left' do
      let(:other_coords) { data.merge('x' => object.x - distance) }
      it { is_expected.to eq('left') }
    end

    describe 'when other location is directly up' do
      let(:other_coords) { data.merge('y' => object.y + distance) }
      it { is_expected.to eq('up') }
    end

    describe 'when other location is directly down' do
      let(:other_coords) { data.merge('y' => object.y - distance) }
      it { is_expected.to eq('down') }
    end

    describe 'when other location is mostly right' do
      let(:other_coords) { {'x' => object.x + further, 'y' => object.y + distance} }
      it { is_expected.to eq('right') }
    end

    describe 'when other location is mostly left' do
      let(:other_coords) { {'x' => object.x - further, 'y' => object.y - distance} }
      it { is_expected.to eq('left') }
    end

    describe 'when other location is mostly up' do
      let(:other_coords) { {'x' => object.x + distance, 'y' => object.y + further} }
      it { is_expected.to eq('up') }
    end

    describe 'when other location is mostly down' do
      let(:other_coords) { {'x' => object.x - distance, 'y' => object.y - further} }
      it { is_expected.to eq('down') }
    end

    describe 'when other location is equally up and right' do
      let(:other_coords) { {'x' => object.x + distance, 'y' => object.y + distance} }
      it { is_expected.to eq('up') }
    end

    describe 'when other location is equally up and left' do
      let(:other_coords) { {'x' => object.x - distance, 'y' => object.y + distance} }
      it { is_expected.to eq('up') }
    end

    describe 'when other location is equally down and right' do
      let(:other_coords) { {'x' => object.x + distance, 'y' => object.y - distance} }
      it { is_expected.to eq('down') }
    end

    describe 'when other location is equally down and left' do
      let(:other_coords) { {'x' => object.x - distance, 'y' => object.y - distance} }
      it { is_expected.to eq('down') }
    end

    describe 'when other location is the same' do
      let(:other_coords) { data }
      it { is_expected.to be_nil }
    end
  end

  describe '#move(requested_direction)' do
    subject { object.move(requested_direction) }

    describe 'when requested direction is right' do
      let(:requested_direction) { 'right' }

      it { is_expected.to be_a(klass) }

      it 'returns x + 1' do
        expect(subject.x).to eq(x + 1)
      end

      it 'returns same y' do
        expect(subject.y).to eq(y)
      end
    end

    describe 'when requested direction is left' do
      let(:requested_direction) { 'left' }

      it { is_expected.to be_a(klass) }

      it 'returns x - 1' do
        expect(subject.x).to eq(x - 1)
      end

      it 'returns same y' do
        expect(subject.y).to eq(y)
      end
    end

    describe 'when requested direction is up' do
      let(:requested_direction) { 'up' }

      it { is_expected.to be_a(klass) }

      it 'returns same x' do
        expect(subject.x).to eq(x)
      end

      it 'returns y + 1' do
        expect(subject.y).to eq(y + 1)
      end
    end

    describe 'when requested direction is down' do
      let(:requested_direction) { 'down' }

      it { is_expected.to be_a(klass) }

      it 'returns same x' do
        expect(subject.x).to eq(x)
      end

      it 'returns y - 1' do
        expect(subject.y).to eq(y - 1)
      end
    end

    describe 'when unrecognized direction is requested' do
      let(:requested_direction) { 'turtles' }
      it { is_expected.to be_nil }
    end
  end
end