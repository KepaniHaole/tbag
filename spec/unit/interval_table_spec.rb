require_relative '../../src/tbag/interval_table'

module Tbag
  describe IntervalTable do
    context 'when given a valid interval hint' do
      [
        # base intervals
        ['second',                 1],
        ['seconds',                1],
        ['minute',                60],
        ['minutes',               60],
        ['hour',                3600],
        ['hours',               3600],
        ['day',                86400],
        ['days',               86400],
        ['week',              604800],
        ['weeks',             604800],
        ['month',            2419200],
        ['months',           2419200],
        ['year',            29030400],
        ['years',           29030400],

        # adverb intervals
        ['continuously',           1],
        ['hourly',              3600],
        ['daily',              86400],
        ['monthly',          2419200],
        ['yearly',          29030400],

        # 'every' intervals
        ['every_second',           1],
        ['every_30_minutes',    1800],
        ['every_5_hours',      18000],
        ['every_day'   ,       86400],
        ['every_8_weeks',    4838400],
        ['every_20_years', 580608000]
      ].each do |data|
        it 'should map to the proper interval' do
          interval = IntervalTable.lookup data[0]
          expect(interval[:seconds]).to eq(data[1])
        end
      end
    end

    context 'when given crap' do
      it 'should return an empty hash' do
        expect { IntervalTable.lookup 'qwefnqlkwen' }.to raise_exception
        expect { IntervalTable.lookup 'nqefkqnkwje' }.to raise_exception
      end
    end
  end
end