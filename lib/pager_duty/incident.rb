require 'rest_client'
require 'yajl'
require 'dalli'

module PagerDuty
  class Incident
    def self.all(params = {})
      json = RestClient.get(PagerDuty.api_url_for_path("/incidents", params))
      Yajl::load(json)["incidents"].map do |hash|
        Incident.new(hash)
      end
    rescue
      []
    end

    def self.triggered
      all(:status => 'triggered')
    end

    def self.webhook_loop(endpoint, interval = 10)
      while true do
        process_triggered_incidents(endpoint)
        sleep interval
      end
    end

    def self.process_triggered_incidents(endpoint)
      incidents = triggered
      if !incidents.empty?
        incidents.each do |incident|
          if !incident.webhook_sent?
            incident.send_webhook(endpoint)
          end
        end
      end
    end

    class << self
      attr_accessor :cache
    end

    def initialize(hash)
      @hash = hash
    end

    def incident_number
      @hash['incident_number']
    end
    alias_method :id, :incident_number

    def last_status_change_on
      @hash['last_status_change_on']
    end

    def webhook_sent?
      self.class.cache.get(self.id) == self.last_status_change_on
    end

    def send_webhook(uri)
      self.class.cache.set(self.id, self.last_status_change_on)
      RestClient.post(uri, @hash)
    end
  end
end