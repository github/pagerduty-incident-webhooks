require 'spec_helper'

describe PagerDuty::Incident do
  context 'in general' do
    before(:each) do
      @incident = PagerDuty::Incident.new(
        "assigned_to_user" => {
          "name"                    => "email",
          "id"                      => "FTYJNBG",
          "html_url"                =>  "http://subdomain.pagerduty.com/users/FTYJNBG",
          "email"                   =>  "email@example.com"
        },
        "trigger_summary_data" => {
          "HOSTSTATE"               => "UP",
          "pd_nagios_object"        => "service",
          "SERVICEDESC"             => "mysql",
          "SERVICESTATE"            => "CRITICAL",
          "HOSTNAME"                => "a1"
        },
        "service" => {
          "name"                    => "nagios",
          "id"                      => "PDQCZQO",
          "html_url"                => "http://subdomain.pagerduty.com/services/PDQCZQO"
        },
        "last_status_change_on"     => "2012-05-24T23:11:37Z",
        "trigger_details_html_url"  => "http://subdomain.pagerduty.com/incidents/PJFCU67/log_entries/P9MBROA",
        "created_on"                => "2012-05-24T23:11:37Z",
        "last_status_change_by"     => nil,
        "status"                    => "triggered",
        "html_url"                  => "http://subdomain.pagerduty.com/incidents/PJFCU67",
        "incident_key"              => "event_source=service;host_name=aux1;service_desc=fs_partition_8",
        "incident_number"           => 934
      )
    end

    it 'provides some accessors' do
      @incident.id.should                    == 934
      @incident.last_status_change_on.should == "2012-05-24T23:11:37Z"
    end

    it 'is marked as unsent before delivery' do
      @incident.webhook_sent?.should be_false
    end

    it 'delivers webhooks' do
      VCR.use_cassette('sample_webhook') do
        @incident.send_webhook('http://requestb.in/1e88aqp1').should be_true
      end
    end

    it 'is marked as sent after delivery' do
      VCR.use_cassette('sample_webhook') do
        @incident.send_webhook('http://requestb.in/1e88aqp1')
      end
      @incident.webhook_sent?.should be_true
      PagerDuty::Incident.new({
        "incident_number"         => 934,
        "last_status_change_on"   => "2012-05-24T23:11:37Z"
      }).webhook_sent?.should be_true
      PagerDuty::Incident.new({
        "incident_number"         => 934,
        "last_status_change_on"   => "2012-05-24T23:11:38Z"
      }).webhook_sent?.should be_false
    end

    it 'returns an empty array when there are no triggered incidents' do
      VCR.use_cassette('empty') do
        PagerDuty::Incident.triggered.should == []
      end
    end

    it 'returns triggered incidents when there some' do
      VCR.use_cassette('incidents') do
        triggered = PagerDuty::Incident.triggered
        triggered.first.id.should == 936
      end
    end
  end
end
