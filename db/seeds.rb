# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require_relative "seeds/collage_books"

if Rails.env.development?
  puts "Seeding database..."

  # Users
  alice = User.find_or_create_by!(email_address: "alice@example.com") do |user|
    user.name = "Alice Wonderland"
    user.password = "password123456"
    user.password_confirmation = "password123456"
  end

  bob = User.find_or_create_by!(email_address: "bob@example.com") do |user|
    user.name = "Bob Belcher"
    user.password = "password123456"
    user.password_confirmation = "password123456"
  end

  puts "Created #{User.count} users"

  # Club
  club = Club.find_or_create_by!(name: "The Knights Radiant") do |c|
    c.description = "A friendly book club for Stormlight Archive fanatics."
    c.created_by = alice
  end

  puts "Created #{Club.count} club(s)"

  # Memberships
  Membership.find_or_create_by!(user: alice, club: club) do |m|
    m.role = :owner
  end

  Membership.find_or_create_by!(user: bob, club: club) do |m|
    m.role = :member
  end

  puts "Created #{Membership.count} membership(s)"

  # Cycle
  unless club.current_cycle
    club.cycles.create!(state: :nominating)
  end

  puts "Cycles: #{Cycle.count}"

  # TODO: Seed Nominations and Votes once those models exist (Day 4/5)

  puts "Done."
end
