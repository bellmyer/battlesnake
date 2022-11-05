RSpec.shared_examples 'model' do
  subject { object }

  it { is_expected.to be_a(Battlesnake::Base) }

  describe '#==(other)' do
    subject { object == other }

    describe 'when other is the same class with matching data' do
      let(:other) { klass.new(data) }
      it { is_expected.to be_truthy }
    end

    describe 'when other is the same class with non-matching data' do
      let(:other) do
        klass.new(data).tap do |o|
          allow(o).to receive(:as_json).and_return({'turtles' => 'i like'})
        end
      end

      it { is_expected.to be_falsey }
    end

    describe 'when other is a different class' do
      let(:other) { 'i like turtles' }
      it { is_expected.to be_falsey }
    end
  end
end