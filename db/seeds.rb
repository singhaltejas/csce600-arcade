# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

initial_games = [
    { name: 'Spelling Bee', game_path: 'spellingbee_path' },
    { name: 'Wordle', game_path: 'wordle_path' },
    { name: 'Letter Boxed', game_path: 'letterboxed_path' }
]

initial_games.each do |game|
    Game.find_or_create_by!(game)
end

roles = [ 'System Admin',
          'Puzzle Aesthetician',
          'Puzzle Setter',
          'Member' ]

roles.each do |role|
  Role.find_or_create_by!(name: role)
end

@user = User.find_or_create_by!(name: "Philip Ritchey", email: "pcr@tamu.edu", role_id: Role.find_by(name: "System Admin").id)
@user.role = Role.find_by(name: "System Admin")
