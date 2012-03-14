module PagerDuty
  class Schedule
    def initialize(id)
      @id = id
    end

    def entries(params)
      params[:since] = format_time_as_iso8601(params[:since])
      params[:until] = format_time_as_iso8601(params[:until])
      result = RestClient.get PagerDuty.api_url_for_path("/schedules/#{@id}/entries", params)
      Yajl::load(result)["entries"].map do |entry|
        entry['start_string'] = Time.parse(entry['start']).iso8601
        entry['start']        = Time.parse(entry['start'])
        entry['end_string']   = Time.parse(entry['end']).iso8601
        entry['end']          = Time.parse(entry['end'])
        entry
      end
    end

    private

    def format_time_as_iso8601(date)
      return date.iso8601
    end
  end
end