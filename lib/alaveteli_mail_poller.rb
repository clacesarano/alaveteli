# -*- encoding : utf-8 -*-
class AlaveteliMailPoller
  require 'net/pop'
  include ConfigHelper

  attr_accessor :settings, :failed_mails

  def initialize(values = {})
    defaults = { address:      AlaveteliConfiguration.pop_mailer_address,
                 port:         AlaveteliConfiguration.pop_mailer_port,
                 user_name:    AlaveteliConfiguration.pop_mailer_user_name,
                 password:     AlaveteliConfiguration.pop_mailer_password,
                 enable_ssl:   AlaveteliConfiguration.pop_mailer_enable_ssl }
    self.settings = defaults.merge(values)
    self.failed_mails = {}
  end

  def poll_for_incoming
    found_mail = false
    start do |pop3|
      pop3.each_mail do |popmail|
        found_mail = true
        get_mail(popmail)
      end
    end
    found_mail
  end

  def self.poll_for_incoming_loop

    # Make a poller and run poll_for_incoming in an endless loop,
    # sleeping when there is nothing to do
    poller = new
    while true
      sleep_seconds = 1
      while !poller.poll_for_incoming
        sleep sleep_seconds
        sleep_seconds *= 2
        sleep_seconds = 300 if sleep_seconds > 300
      end
    end
  end

  private

  def get_mail(popmail)
    unique_id = nil
    raw_email = nil
    received = false
    begin
      unique_id = popmail.unique_id
      if retrieve?(unique_id)
        raw_email = popmail.pop
        RequestMailer.receive(raw_email)
        received = true
        popmail.delete
      end
    rescue Net::POPError, StandardError => error
      if send_exception_notifications?
        ExceptionNotifier.notify_exception(error, :data => { mail: raw_email,
                                                             unique_id: unique_id })
      end
      record_error(unique_id, received, error)
    end
  end

  def record_error(unique_id, received, error)
    if unique_id
      retry_at = received ? nil : Time.zone.now + 30.minutes
      ime = IncomingMessageError.find_or_create_by!(unique_id: unique_id)
      ime.retry_at = retry_at
      ime.backtrace = error.backtrace.join("\n")
      ime.save!
    end
  end

  def failed?(unique_id)
    IncomingMessageError.exists?(unique_id: unique_id)
  end

  def retry?(unique_id)
    incoming_message_error = IncomingMessageError.
      where(unique_id: unique_id).take
    incoming_message_error && incoming_message_error.retry_at < Time.zone.now
  end

  def retrieve?(unique_id)
    !failed?(unique_id) || retry?(unique_id)
  end


  # Start a POP3 session and ensure that it will be closed in any case.
  def start(&block)
    raise ArgumentError.new("AlaveteliMailPoller#start takes a block") unless block_given?

    pop3 = Net::POP3.new(settings[:address], settings[:port], false)
    pop3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if settings[:enable_ssl]
    pop3.start(settings[:user_name], settings[:password])

    yield pop3
  ensure
    if defined?(pop3) && pop3 && pop3.started?
      pop3.finish
    end
  end

end
