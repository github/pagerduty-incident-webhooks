module PagerDuty
  class Incident
    def self.all(params = {})
      Yajl::load(RestClient.get PagerDuty.api_url_for_path("/incidents", params))["incidents"]
    end

    def self.triggered
      all(:status => 'triggered')
    end
  end
end