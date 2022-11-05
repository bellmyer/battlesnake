require 'json'

describe Battlesnake::Board do
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
        Battlesnake::Location.new(x, y)
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

    it 'includes all food locations' do
      food_locations.each { |location| is_expected.to include(location) }
    end

    it 'includes all hazard locations' do
      hazard_locations.each { |location| is_expected.to include(location) }
    end

    it 'excludes empty locations' do
      empty_locations.each { |location| is_expected.to_not include(location) }
    end

    it 'memoizes the result' do
      expect(object).to receive(:snakes).and_return([]).once
      expect(object).to receive(:food).and_return([]).once
      expect(object).to receive(:hazards).and_return([]).once

      2.times { object.occupied_locations }
    end
  end

  describe '#occupied?(location)' do
    subject { object.occupied?(*location_params) }

    describe 'when location is occupied' do
      let(:location) { Battlesnake::Location.new(occupied_locations.first) }

      describe 'when location param is a Location object' do
        let(:location_params) { [location] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is a hash' do
        let(:location_params) { [location.as_json] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is an array of x,y coordinates' do
        let(:location_params) { [[location.x, location.y]] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is a pair of x,y parameters' do
        let(:location_params) { [location.x, location.y] }
        it { is_expected.to be_truthy }
      end
    end

    describe 'when location is NOT occupied' do
      let(:location) { Battlesnake::Location.new(empty_locations.first) }

      describe 'when location param is a Location object' do
        let(:location_params) { [location] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is a hash' do
        let(:location_params) { [location.as_json] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is an array of x,y coordinates' do
        let(:location_params) { [[location.x, location.y]] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is a pair of x,y parameters' do
        let(:location_params) { [location.x, location.y] }
        it { is_expected.to be_falsey }
      end
    end
  end


  describe '#available?(location)' do
    subject { object.available?(*location_params) }

    describe 'when location is occupied' do
      let(:location) { Battlesnake::Location.new(occupied_locations.first) }

      describe 'when location param is a Location object' do
        let(:location_params) { [location] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is a hash' do
        let(:location_params) { [location.as_json] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is an array of x,y coordinates' do
        let(:location_params) { [[location.x, location.y]] }
        it { is_expected.to be_falsey }
      end

      describe 'when location param is a pair of x,y parameters' do
        let(:location_params) { [location.x, location.y] }
        it { is_expected.to be_falsey }
      end
    end

    describe 'when location is NOT occupied' do
      let(:location) { Battlesnake::Location.new(empty_locations.first) }

      describe 'when location param is a Location object' do
        let(:location_params) { [location] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is a hash' do
        let(:location_params) { [location.as_json] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is an array of x,y coordinates' do
        let(:location_params) { [[location.x, location.y]] }
        it { is_expected.to be_truthy }
      end

      describe 'when location param is a pair of x,y parameters' do
        let(:location_params) { [location.x, location.y] }
        it { is_expected.to be_truthy }
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

    let(:obstacle) { Battlesnake::Location.new(1, 1) }

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
end