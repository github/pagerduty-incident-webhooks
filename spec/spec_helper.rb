$: << File.expand_path("../../lib", Pathname.new(__FILE__).realpath)

require 'pager_duty'
require 'vcr'

PagerDuty.config = {
  :account_subdomain => 'subdomain',
  :auth_email        => 'email@example.com',
  :auth_password     => 'omgsecretsauce',
}

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
end

class OmgFakeCache
  def initialize
    @cache = []
  end

  def set(key, value)
    @cache[key] = value
  end

  def get(key)
    @cache[key]
  end
end

PagerDuty::Incident.cache = OmgFakeCache.new