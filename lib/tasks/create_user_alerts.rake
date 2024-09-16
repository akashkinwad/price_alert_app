namespace :create_user_alerts do
  desc 'Create a user with seed data for alerts. Pass the current price as an argument, e.g., rake create_user_alerts:create[60000]'
  task :create, [:current_price] => :environment do |_t, args|
    current_price = args[:current_price].to_f.nonzero? || 58000

    user = User.find_or_create_by!(
      email: 'user@example.com'
    ) do |u|
      u.password = 'password123'
      u.password_confirmation = 'password123'
    end

    puts "Created or found user with email: #{user.email}"

    (1..10000).each do |i|
      random_movement = rand(-1000.0..3000.0).round(2)
      random_decimal = rand.round(2)
      target_price = current_price + random_movement + random_decimal

      Alert.create!(
        user: user,
        coin_name: 'BTC',
        target_price: target_price.round(2)
      )
    end

    puts "Seeded user #{user.email} with data"
    puts '--------------------------------------'
    puts "Email: #{user.email}"
    puts "Token: #{user.generate_jwt}"
    puts '--------------------------------------'
  end
end
