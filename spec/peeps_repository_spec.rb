require 'peeps_repository'

def reset_peeps_table
  seed_sql = File.read('spec/seeds/chitter_test.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'chitter_database_test' })
  connection.exec(seed_sql)
end

describe PeepsRepository do
  before(:each) do
    reset_peeps_table
  end

  it 'shows all the peeps content' do
    repo = PeepsRepository.new
    expect(repo.all.length).to eq 3
    expect(repo.all[0].peep_content).to eq('Welcome to chitter')
  end

# it 'find one peep by id and time' do
#       repo = PeepsRepository.new
#       peep = repo.find(1)
#       expect(peep.content).to eq 'Welcome to chitter'
#       expect(peep.user_id).to eq 1
#       peep = repo.find(2)
#       expect(peep.time_posted.strftime("%Y-%m-%d %H:%M:%S")).to eq '2023-03-22 15:00:00'
#   end
end