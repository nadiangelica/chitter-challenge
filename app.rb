require 'sinatra/base'
require 'sinatra/reloader'
require './lib/database_connection'
require './controllers/peeps_controller'
require './controllers/user_controller'
require './lib/peeps_repository'

# Connect to the chitter_database
DatabaseConnection.connect('chitter_database')

class Application < Sinatra::Base
  configure do
    enable :sessions
    set :views, File.join(__dir__, 'views')
    set :public_dir, './public'
    
    before do
      @peeps_repo = PeepsRepository.new(DatabaseConnection.setup('chitter_database'))
    end

    # Instantiate repositories
    @@peeps_repo = PeepsRepository.new(DatabaseConnection)
    @@user_repo = UserRepository.new
  end

  use SignupController
  use PeepsController

  def self.peeps_repo
    @@peeps_repo
  end

  def self.user_repo
    @@user_repo
  end
end
