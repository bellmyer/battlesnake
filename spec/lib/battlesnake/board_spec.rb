require 'json'

describe Battlesnake::Board do
  let(:klass) { Battlesnake::Board }
  let(:object) { klass.new(attribs) }

  let(:attribs) { data }
  let(:json) { data.to_json }
  let(:data) { Fabricate(:board).as_json }

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
end