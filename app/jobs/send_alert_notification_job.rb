class SendAlertNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_ids)
    User.where(id: user_ids).find_each do |user|
      puts "Sending price trigger alert notification to user #{user.email}"
      # AlertMailer.alert_triggered(user).deliver_later
    end
  end
end
