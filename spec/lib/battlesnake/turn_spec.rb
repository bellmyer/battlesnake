describe Battlesnake::Turn do
  let(:klass) { Battlesnake::Turn }
  let(:object) { klass.new(attribs) }

  let(:attribs) { data }
  let(:json) { data.to_json }
  let(:data) { Fabricate(:turn).as_json }

  describe '#initialize(json_or_string)' do
    subject { object }

    describe "when attributes are passed as hash" do
      let(:attribs) { data }

      it 'sets as_json' do
        expect(subject.as_json).to eq(data)
      end

      it 'sets game to hash' do
        expect(subject.game).to be_a(Hash)
        expect(subject.game).to eq(data['game'])
      end

      it 'sets board to Board instance' do
        expect(subject.board).to be_a(Battlesnake::Board)
        expect(subject.board.as_json).to eq(data['board'])
      end

      it 'sets you to Snake instance' do
        expect(subject.you).to be_a(Battlesnake::Snake)
        expect(subject.you.as_json).to eq(data['you'])
      end
    end

    describe "when attributes are passed as string" do
      let(:attribs) { json }

      it 'sets as_json' do
        expect(subject.as_json).to eq(data)
      end

      it 'sets game to hash' do
        expect(subject.game).to be_a(Hash)
        expect(subject.game).to eq(data['game'])
      end

      it 'sets board to Board instance' do
        expect(subject.board).to be_a(Battlesnake::Board)
        expect(subject.board.as_json).to eq(data['board'])
      end

      it 'sets you to Snake instance' do
        expect(subject.you).to be_a(Battlesnake::Snake)
        expect(subject.you.as_json).to eq(data['you'])
      end
    end
  end

  describe '#others' do
    subject { object.others }

    it { is_expected.to be_an(Array) }

    it 'is one less than all board snakes' do
      expect(subject.size).to eq(object.board.snakes.size - 1)
    end

    it 'omits your snake' do
      other_ids = subject.map(&:id)
      your_id = object.you.id

      expect(other_ids).to_not include(your_id)
    end

    it 'memoizes the result' do
      expect(object.board).to receive(:snakes).once.and_return([])
      2.times { object.others }
    end
  end
end