require 'json'

describe Battlesnake::Snake do
  let(:klass) { Battlesnake::Snake }
  let(:object) { klass.new(attribs) }

  let(:json) { data.to_json }
  let(:data) { Fabricate(:snake).raw }

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
        expect(subject.raw).to eq(data)
      end

      it_sets_attr(:id)
      it_sets_attr(:name)
      it_sets_attr(:latency)
      it_sets_attr(:health)
      it_sets_attr(:length)
      it_sets_attr(:shout)
      it_sets_attr(:squad)
      it_sets_attr(:customizations)

      it 'sets body' do
        body = subject.body

        expect(body).to be_an(Array)

        body.each do |segment|
          expect(segment).to be_a(Battlesnake::Location)
          expect(data['body']).to include({'x' => segment.x, 'y' => segment.y})
        end
      end

      it 'sets head' do
        head = subject.head

        expect(head).to be_a(Battlesnake::Location)
        expect({'x' => head.x, 'y' => head.y}).to eq(data['head'])
      end
    end

    describe 'when attributes are passed as JSON' do
      let(:attribs) { json }

      it { is_expected.to be_a(klass) }

      it 'stores the raw input data' do
        expect(subject.raw).to eq(data)
      end
    end
  end
end