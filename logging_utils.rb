class LoggingUtils

  def self.log(log_str)
    time = Time.new
    puts time.strftime("%Y-%m-%d %H:%M:%S") + " " + log_str
  end

end