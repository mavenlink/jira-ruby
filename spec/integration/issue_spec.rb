require 'spec_helper'

describe JIRA::Resource::Issue do

  with_each_client do |site_url, client|
    let(:client) { client }
    let(:site_url) { site_url }


    let(:key) { "10002" }

    let(:expected_attributes) do
      {
        'self'   => "http://localhost:2990/jira/rest/api/2/issue/10002",
        'key'    => "SAMPLEPROJECT-1",
        'expand' => "renderedFields,names,schema,transitions,editmeta,changelog"
      }
    end

    let(:attributes_for_post) {
      { 'foo' => 'bar' }
    }
    let(:expected_attributes_from_post) {
      { "id" => "10005", "key" => "SAMPLEPROJECT-4" }
    }

    let(:attributes_for_put) {
      { 'foo' => 'bar' }
    }
    let(:expected_attributes_from_put) {
      { 'foo' => 'bar' }
    }
    let(:expected_collection_length) { 11 }

    it_should_behave_like "a resource"
    it_should_behave_like "a resource with a singular GET endpoint"
    describe "GET all issues" do # JIRA::Resource::Issue.all uses the search endpoint
      let(:client) { client }
      let(:site_url) { site_url }

      let(:expected_attributes) {
        {
          "id"=>"10014",
          "self"=>"http://localhost:2990/jira/rest/api/2/issue/10014",
          "key"=>"SAMPLEPROJECT-13"
        }
      }
      before(:each) do
        stub_request(:get, site_url + "/jira/rest/api/3/search/jql?expand=transitions.fields").
                    to_return(:status => 200, :body => get_mock_response('issue.json'))
      
        stub_request(:get, "http://localhost:2990/rest/api/3/search/jql?expand=transitions.fields")
          .with(headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>/OAuth .*/, # Use a regex to match any OAuth header
            'User-Agent'=>'OAuth gem v0.5.14'
          })
          .to_return(status: 200, body: get_mock_response('issue.json'), headers: {})
        stub_request(:get, "http://foo:bar@localhost:2990/rest/api/3/search/jql?expand=transitions.fields")
                    .with(headers: {
                    'Accept'=>'application/json',
                    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                    'User-Agent'=>'Ruby'
        })
    .to_return(status: 200, body: get_mock_response('issue.json'), headers: {})
    end
      it_should_behave_like "a resource with a collection GET endpoint"
    end
    it_should_behave_like "a resource with a DELETE endpoint"
    it_should_behave_like "a resource with a POST endpoint"
    it_should_behave_like "a resource with a PUT endpoint"
    it_should_behave_like "a resource with a PUT endpoint that rejects invalid fields"

    describe "errors" do
      before(:each) do
        stub_request(:get,
                    site_url + "/jira/rest/api/2/issue/10002").
                    to_return(:status => 200, :body => get_mock_response('issue/10002.json'))
        stub_request(:put, site_url + "/jira/rest/api/2/issue/10002").
                    with(:body => '{"missing":"fields and update"}').
                    to_return(:status => 400, :body => get_mock_response('issue/10002.put.missing_field_update.json'))
      end

      it "fails to save when fields and update are missing" do
        subject = client.Issue.build('id' => '10002')
        subject.fetch
        expect(subject.save('missing' => 'fields and update')).to be_falsey
      end

    end

    describe "GET jql issues" do # JIRA::Resource::Issue.jql uses the search endpoint
      jql_query_string = "PROJECT = 'SAMPLEPROJECT'"
      let(:client) { client }
      let(:site_url) { site_url }
      let(:jql_query_string) { jql_query_string }

      let(:expected_attributes) {
        {
          "id"=>"10014",
          "self"=>"http://localhost:2990/jira/rest/api/2/issue/10014",
          "key"=>"SAMPLEPROJECT-13"
        }
      }
      before(:each) do
        stub_request(:get, "http://foo:bar@localhost:2990/rest/api/3/search/jql?jql=PROJECT%20=%20'SAMPLEPROJECT'")
          .with(headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent'=>'Ruby'
          })
          .to_return(status: 200, body: get_mock_response('issue.json'), headers: {})
        stub_request(:get, "http://localhost:2990/rest/api/3/search/jql?jql=PROJECT%20=%20'SAMPLEPROJECT'")
          .with(headers: {
            'Accept'=>'application/json',
            'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization'=>/OAuth .*/, # Use a regex to match any OAuth header
            'User-Agent'=>'OAuth gem v0.5.14'
    })
  .to_return(status: 200, body: get_mock_response('issue.json'), headers: {})
        end
      it_should_behave_like "a resource with JQL inputs and a collection GET endpoint"
    end

  end
end
