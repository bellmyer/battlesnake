require 'json'

describe Battlesnake::Game do
  let(:klass) { Battlesnake::Game }
  let(:object) { klass.new(attribs) }

  let(:attribs) { data }
  let(:json) { data.to_json }
  let(:data) { Fabricate(:game).as_json }

  it_behaves_like 'model'

  describe '#initialize(json_or_hash)' do
    subject { object }

    def self.it_sets_attr(name)
      it "sets #{name}" do
        attribute = subject.send(name)

        expect(attribute).to_not be_nil
        expect(attribute).to eq(data[name.to_s])
      end
    end

    describe 'when attributes are passed as a hash' do
      let(:attribs) { data }

      it { is_expected.to be_a(klass) }

      it 'stores the raw input data' do
        expect(subject.as_json).to eq(data)
      end

      it_sets_attr(:id)
      it_sets_attr(:ruleset)
      it_sets_attr(:map)
      it_sets_attr(:timeout)
      it_sets_attr(:source)
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