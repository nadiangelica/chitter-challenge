require_relative 'peeps'
require_relative 'user'
require_relative 'user_repository'

class PeepsRepository
  def initialize(repo)
    @user_repo = repo
    @all_peeps = [] # Initialize an empty array to store all the peeps
  end

  def all
    query = "SELECT p.*, u.username FROM peeps p INNER JOIN users u ON p.user_id = u.id ORDER BY p.time_of_peep ASC"
    result = DatabaseConnection.query(query)

    result.map do |peep|
      Peep.new(
        id: peep['id'],
        peep_content: peep['peep_content'],
        user_id: peep['user_id'],
        time_of_peep: peep['time_of_peep'],
        username: peep['username']
      )
    end
  end

  def create(peep)
    sql = 'INSERT INTO peeps (peep_content, user_id, time_of_peep) VALUES ($1, $2, $3) RETURNING *;'
    sql_params = [peep.peep_content, peep.user_id, peep.time_of_peep]
    result = DatabaseConnection.exec_params(sql, sql_params)

    puts "Result: #{result}"

    if result.any?
      peep_data = result[0]
      puts "Peep Data: #{peep_data}"
      peep.id = peep_data['id'].to_i # Assign the id from the database to the peep object
      peep.username = @user_repo.find(peep.user_id).username # Assign the username to the peep object
      @all_peeps << peep # Add the newly created peep to the list of all peeps
      @all_peeps.sort_by!(&:time_of_peep) # Sort the peeps by time_of_peep
      peep
    else
      nil
    end
  end

  public

  def all_with_users
    query = "SELECT p.*, u.username FROM peeps p INNER JOIN users u ON p.user_id = u.id ORDER BY p.time_of_peep DESC"
    result = DatabaseConnection.query(query)

    result.map do |peep|
      Peep.new(
        id: peep['id'],
        peep_content: peep['peep_content'],
        user_id: peep['user_id'],
        time_of_peep: peep['time_of_peep'],
        username: peep['username']
      )
    end
  end

  def find(id)
    puts id.inspect # Add this line to see the value of id
    query = "SELECT p.*, u.username FROM peeps p INNER JOIN users u ON p.user_id = u.id WHERE p.id = $1"
    result = DatabaseConnection.exec_params(query, [id])
    if result.any?
      peep = Peep.new(
        id: result[0]['id'],
        peep_content: result[0]['peep_content'],
        user_id: result[0]['user_id'],
        time_of_peep: result[0]['time_of_peep'],
        username: result[0]['username']
      )
      peep
    else
      nil
    end
  end

  def delete(id)
    sql = 'DELETE FROM peeps WHERE id = $1 RETURNING *;'
    sql_params = [id]
    result = DatabaseConnection.exec_params(sql, sql_params)
  end

  def update(peep)
    sql = 'UPDATE peeps SET peep_content = $1 WHERE id = $2;'
    sql_params = [peep.peep_content, peep.id]
    result = DatabaseConnection.exec_params(sql, sql_params)
    result.to_a.empty? ? nil : peep
  end
end
