require 'stringio'

RSpec.shared_context 'Rails.loggerの出力内容がlog_stringとして参照できる', :stub_logging do
  around do |example|
    backup = Rails.logger
    begin
      Rails.logger = Logger.new(log_string_io)
      example.run
    ensure
      Rails.logger = backup
    end
  end

  let(:log_string) { log_string_io.string }
  let(:log_string_io) { StringIO.new }
end
