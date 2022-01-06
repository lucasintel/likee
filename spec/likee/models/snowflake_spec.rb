# frozen_string_literal: true

RSpec.describe Likee::Snowflake do
  describe '#timestamp' do
    context 'when snowflake is a Integer' do
      subject { described_class.new(6914348117433371910) }

      it 'returns the timestamp' do
        expect(subject.timestamp).to eq(Time.parse('2021-01-05T18:42:02Z'))
      end
    end

    context 'when snowflake is a String' do
      subject { described_class.new('6914348117433371910') }

      it 'returns the timestamp' do
        expect(subject.timestamp).to eq(Time.parse('2021-01-05T18:42:02Z'))
      end
    end

    context 'when snowflake is invalid' do
      subject { described_class.new('abcd') }

      it 'raises ArgumentError' do
        expect { subject.timestamp }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#inspect' do
    subject { described_class.new(6914348117433371910) }

    it 'formats the snowflake' do
      expect(subject.inspect).to eq("#<Likee::Snowflake @id=#{subject.id} @timestamp=#{subject.timestamp}>")
    end
  end

  describe '#to_i' do
    subject { described_class.new(6914348117433371910) }

    it 'returns the snowflake id' do
      expect(subject.to_i).to eq(6914348117433371910)
    end
  end

  describe '#to_s' do
    subject { described_class.new(6914348117433371910) }

    it 'returns the snowflake id as a string' do
      expect(subject.to_s).to eq('6914348117433371910')
    end
  end

  describe 'Comparable Behaviour' do
    it 'computes equality based on snowflake id' do
      snowflake1 = described_class.new('6914348117433371910')
      snowflake2 = described_class.new('6914348117433371910')

      expect(snowflake1 == snowflake2).to be_truthy
    end

    it 'computes comparisons based on snowflake id' do
      snowflake1 = described_class.new('6914348117433371910')
      snowflake2 = described_class.new('6914348117433371920')

      expect(snowflake2 > snowflake1).to be_truthy
    end
  end
end
