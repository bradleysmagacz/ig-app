class JobError < StandardError
  attr_reader :severity

  SEVERITIES = %w(:none, :error, :fatal).freeze

  def initialize(severity = :error, message = '')
    super message
    @severity = severity
    Rails.logger.error "JobError (#{severity}): #{message}"
  end
end
