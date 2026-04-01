class WriteProductToFileJob < ApplicationJob
  queue_as :default

  def perform(user_params)
    logger = Logger.new("log/debug.log")
    logger.info "Job is running: #{self.class.name}"
    logger.info "Parameters: #{user_params}"
  end
end
