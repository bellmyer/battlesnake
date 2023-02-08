require 'json'

describe Battlesnake::Board do
  def loc(structure)
    case structure
    when Hash
      Battlesnake::Location.new(structure['x'], structure['y'])
    when Array
      Battlesnake::Location.new(*structure)
    when Location
      Battlesnake::Location.new(structure.x, structure.y)
    end
  end

  let(:klass) { Battlesnake::Board }
  let(:object) { klass.new(attribs) }

  let(:attribs) { data }
  let(:json) { data.to_json }
  let(:data) { Fabricate(:board).as_json }

  let(:snake_locations) { object.snakes.map(&:body).flatten.map(&:as_json) }
  let(:food_locations) { object.food.map(&:as_json) }
  let(:hazard_locations) { object.hazards.map(&:as_json) }

  let(:occupied_locations) { [snake_locations, food_locations, hazard_locations].reduce(:+) }
  let(:empty_locations) { all_locations - occupied_locations }

  let(:all_locations) do
    object.width.times.map do |x|
      object.height.times.map do |y|
        loc([x, y])
      end
    end.flatten.map(&:as_json)
  end

  it_behaves_like('model')

  describe '#initialize(json_or_hash)' do
    subject { object }

    def self.it_sets_attr(name)
      it "sets #{name}" do
        attribute = subject.send(name)

        expect(attribute).to_not be_nil
        expect(attribute).to eq(data[name.to_s])
      end
    end

    def self.it_sets_array(name, class_name)
      it "sets #{name} as an array of #{class_name} objects" do
        objects = subject.send(name)
        expected_class = eval(class_name)

        expect(objects).to be_an(Array)
        expect(objects).to_not be_empty

        objects.each{ |o| expect(o).to be_an(expected_class) }
      end
    end

    describe 'when attributes are passed as a hash' do
      let(:attribs) { data }

      it { is_expected.to be_a(klass) }

      it 'stores the raw input data' do
        expect(subject.as_json).to eq(data)
      end

      it_sets_attr(:height)
      it_sets_attr(:width)

      it_sets_array(:snakes, 'Battlesnake::Snake')
      it_sets_array(:food, 'Battlesnake::Location')
      it_sets_array(:hazards, 'Battlesnake::Location')
    end

    describe 'when attributes are passed as a JSON string' do
      let(:attribs) { json }

      it { is_expected.to be_a(klass) }

      it 'stores the raw input data' do
        expect(subject.as_json).to eq(data)
      end
    end
  end

  describe '#occupied_locations' do
    subject { object.occupied_locations.map(&:as_json) }

    it { is_expected.to be_an(Array) }

    it 'includes all snake body locations' do
      snake_locations.each { |location| is_expected.to include(location) }
    end

    it 'includes all hazard locations' do
      hazard_locations.each { |location| is_expected.to include(location) }
    end

    it 'excludes all food locations' do
      food_locations.each { |location| is_expected.to_not include(location) }
    end

    it 'excludes empty locations' do
      empty_locations.each { |location| is_expected.to_not include(location) }
    end

    it 'memoizes the result' do
      expect(object).to receive(:snakes).and_return([]).once
      expect(object).to receive(:hazards).and_return([]).once

      2.times { object.occupied_locations }
    end
  end

  describe '#occupied?(location)' do
    subject { object.occupied?(location) }

    describe 'when location is occupied' do
      let(:location) { loc(occupied_locations.first) }
      it { is_expected.to be_truthy }
    end

    describe 'when location is NOT occupied' do
      let(:location) { loc(empty_locations.first) }
      it { is_expected.to be_falsey }
    end
  end

  describe '#food?(location)' do
    subject { object.food?(location) }

    describe 'when location is occupied' do
      let(:location) { loc(occupied_locations.first) }
      it { is_expected.to be_falsey }
    end

    describe 'when location is empty' do
      let(:location) { loc(empty_locations.first) }
      it { is_expected.to be_falsey }
    end

    describe 'when location is food' do
      let(:location) { loc(food_locations.first) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#available?(location)' do
    subject { object.available?(location) }

    let(:on_board?) { true }

    before { allow(object).to receive(:on_board?).with(location).and_return(on_board?) }

    describe 'when location is occupied' do
      let(:location) { loc(occupied_locations.first) }

      describe 'when location is within board boundaries' do
        let(:on_board?) { true }
        it { is_expected.to be_falsey }
      end

      describe 'when location is NOT within board boundaries' do
        let(:on_board?) { false }
        it { is_expected.to be_falsey }
      end
    end

    describe 'when location is NOT occupied' do
      let(:location) { loc(empty_locations.first) }

      describe 'when location is within board boundaries' do
        let(:on_board?) { true }
        it { is_expected.to be_truthy }
      end

      describe 'when location is NOT within board boundaries' do
        let(:on_board?) { false }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '#available_directions(location)' do
    subject { object.available_directions(location) }

    let(:data) do
      {
        'width' => 11,
        'height' => 11,
        'snakes' => [],
        'food' => [],
        'hazards' => [obstacle.as_json]
      }
    end

    let(:obstacle) { loc([2, 2]) }

    def self.it_returns_only(*valid_directions)
      it { is_expected.to be_an(Array) }

      it 'includes valid directions' do
        valid_directions.each { |direction| is_expected.to include(direction) }
      end

      it 'does NOT include other directions' do
        (Battlesnake::Location::DIRECTIONS - valid_directions).each do |direction|
          is_expected.to_not include(direction)
        end
      end
    end

    describe 'when obstacle is to the right of location' do
      let(:location) { obstacle.move('left') }
      it_returns_only 'up', 'down', 'left'
    end

    describe 'when obstacle is to the left of location' do
      let(:location) { obstacle.move('right') }
      it_returns_only 'up', 'down', 'right'
    end

    describe 'when obstacle is above location' do
      let(:location) { obstacle.move('down') }
      it_returns_only 'down', 'left', 'right'
    end

    describe 'when obstacle is under location' do
      let(:location) { obstacle.move('up') }
      it_returns_only 'up', 'left', 'right'
    end
  end

  describe '#on_board?(location)' do
    subject { object.on_board?(location) }

    let(:location) { loc([x, y]) }
    let(:x) { 1 }
    let(:y) { 1 }

    describe 'when x and y are valid' do
      it { is_expected.to be_truthy }
    end

    describe 'when x is negative' do
      let(:x) { -1 }
      it { is_expected.to be_falsey }
    end

    describe 'when y is negative' do
      let(:y) { -1 }
      it { is_expected.to be_falsey }
    end

    describe 'when x is too high' do
      let(:x) { object.width }
      it { is_expected.to be_falsey }
    end

    describe 'when y is too high' do
      let(:y) { object.height }
      it { is_expected.to be_falsey }
    end
  end

  describe '#flood_fills(from, max: nil)' do
    subject do
      object.flood_fills(object.snakes.first.head, options).transform_values(&:size)
    end

    let(:object) { Scenario.new(scenario).to_board }
    let(:options) { {} }

    describe 'when snake is cornering itself' do
      let(:scenario) do
        <<~DATA
          ##0#
          >>^#
          ####
          ####
        DATA
      end

      it { is_expected.to eq({'up' => 0, 'down' => 0, 'left' => 2, 'right' => 10}) }
    end

    describe 'when max is specified' do
      let(:options) { {max: max} }
      let(:max) { 5 }
      let(:scenario) do
        <<~DATA
          #F0#
          >>^#
          ##F#
          ####
        DATA
      end

      it { is_expected.to eq({'up' => 0, 'down' => 0, 'left' => 2, 'right' => max}) }
    end

    describe 'when there is food' do
      let(:scenario) do
        <<~DATA
          #F0#
          >>^#
          ##F#
          ####
        DATA
      end

      it { is_expected.to eq({'up' => 0, 'down' => 0, 'left' => 2, 'right' => 10}) }
    end

    describe 'when there are hazards' do
      let(:scenario) do
        <<~DATA
          H#0#
          >>^#
          ##H#
          ####
        DATA
      end

      it { is_expected.to eq({'up' => 0, 'down' => 0, 'left' => 1, 'right' => 9}) }
    end

    describe 'when no direction is inhibited' do
      let(:scenario) do
        <<~DATA
          ####
          #>0#
          ####
          ####
        DATA
      end

      it { is_expected.to eq({'up' => 14, 'down' => 14, 'left' => 0, 'right' => 14}) }
    end
  end

  describe '#find_path(from, to)' do
    subject { object.find_path(from, to, max_distance: max_distance) }

    let(:object) { Fabricate(:board, width: dimensions, height: dimensions, snake_count: 0, food_count: 0, hazard_count: 0) }
    let(:from) { loc([0, 0]) }
    let(:to)   { loc([dimensions - 1, dimensions - 1]) }
    let(:max_distance) { nil }

    def self.it_returns_shortest_path_for(dimension_size)
      describe 'when board is 4x4' do
        let(:dimensions) { dimension_size }
        it { expect(subject.size).to eq(dimensions * 2 - 1) }
      end
    end

    describe 'when board is 2x2' do
      let(:dimensions) { 2 }

      let(:upleft) { loc([0, 1]) }
      let(:upright) { loc([1, 1]) }

      let(:downleft) { loc([0, 0]) }
      let(:downright) { loc([1, 0]) }

      let(:shortest_paths) do
        [
          [downleft, upleft, upright],
          [downleft, downright, upright]
        ]
      end

      describe 'when locations are in opposite corners' do
        let(:from) { downleft }
        let(:to) { upright }

        it { is_expected.to be_an(Array) }

        it 'is one of the pre-determined possible paths' do
          expect(shortest_paths).to include(subject)
        end
      end

      describe 'when locations are adjacent' do
        let(:from) { downleft }
        let(:to) { downright }

        it { is_expected.to be_an(Array) }

        it 'returns the direct path' do
          is_expected.to eq([downleft, downright])
        end
      end
    end

    describe 'when board is 3x3' do
      let(:dimensions) { 3 }

      let(:loc_00) { loc([0, 0]) }
      let(:loc_01) { loc([0, 1]) }
      let(:loc_02) { loc([0, 2]) }

      let(:loc_10) { loc([1, 0]) }
      let(:loc_11) { loc([1, 1]) }
      let(:loc_12) { loc([1, 2]) }

      let(:loc_20) { loc([2, 0]) }
      let(:loc_21) { loc([2, 1]) }
      let(:loc_22) { loc([2, 2]) }

      let(:shortest_paths) do
        [
          [loc_00, loc_01, loc_02, loc_12, loc_22],
          [loc_00, loc_10, loc_20, loc_21, loc_22],
          [loc_00, loc_01, loc_11, loc_21, loc_22],
          [loc_00, loc_10, loc_11, loc_21, loc_22],
          [loc_00, loc_01, loc_11, loc_21, loc_22],
          [loc_00, loc_10, loc_11, loc_12, loc_22]
        ]
      end

      describe 'when locations are in opposite corners' do
        it { is_expected.to be_an(Array) }

        it 'includes of of the pre-determined possible paths' do
          expect(shortest_paths).to include(subject)
        end

        describe 'when max_distance is below manhattan distance' do
          let(:max_distance) { 3 }

          it { is_expected.to be_nil }

          it 'does not attempt to recurse into paths' do
            expect(object).to receive(:recursive_paths).never
            subject
          end
        end
      end
    end

    it_returns_shortest_path_for(4)
    it_returns_shortest_path_for(8)
    it_returns_shortest_path_for(12)
    it_returns_shortest_path_for(16)
    it_returns_shortest_path_for(32)
    it_returns_shortest_path_for(64)
  end
end