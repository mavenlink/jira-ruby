RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "http://foo:bar@localhost:2990/jira/rest/api/2/field")
      .with(headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      })
      .to_return(:status => 200, :body => '[{"id":"1","name":"Description","custom":false,"orderable":true,"navigable":true,"searchable":true,"clauseNames":["description"],"schema":{"type":"string","system":"description"}},{"id":"2","name":"Summary","custom":false,"orderable":true,"navigable":true,"searchable":true,"clauseNames":["summary"],"schema":{"type":"string","system":"summary"}}]', :headers => {})
    stub_request(:get, "http://foo:bar@localhost:2990/jira/rest/api/2/project")
      .with(headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      })
      .to_return(:status => 200, :body => '', :headers => {})

    stub_request(:get, "http://foo:bar@localhost:2990/rest/api/3/search/jql?jql=project=%22SAMPLEPROJECT%22")
      .with(headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      })
      .to_return(:status => 200, :body => '{ "issues": [ {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {} ] }', :headers => {})

    stub_request(:get, "http://localhost:2990/rest/api/3/search/jql?jql=project=%22SAMPLEPROJECT%22")
      .with(headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>/OAuth .*/,
        'User-Agent'=>/OAuth gem.*/
      })
      .to_return(:status => 200, :body => '{ "issues": [ {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {} ] }', :headers => {})

    stub_request(:get, "http://foo:bar@localhost:2990/jira/rest/api/2/comment")
      .with(headers: {
        'Accept'=>'application/json',
        'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent'=>'Ruby'
      })
      .to_return(:status => 200, :body => '{"comments":[{"self":"http://localhost:2990/jira/rest/api/2/issue/10002/comment/10000","id":"10000","body":"This is a comment. Creative."},{"self":"http://localhost:2990/jira/rest/api/2/issue/10002/comment/10001","id":"10001","body":"Another comment."}]}', :headers => {})
  end
end
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_support/core_ext/hash'
require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
require 'pry'
Dir["./spec/support/**/*.rb"].each {|f| require f}

require 'jira'

RSpec.configure do |config|
  config.extend ClientsHelper
end


def get_mock_response(file, value_if_file_not_found = false)
  begin
    file.sub!('?', '_') # we have to replace this character on Windows machine
    File.read(File.join(File.dirname(__FILE__), 'mock_responses/', file))
  rescue Errno::ENOENT => e
    raise e if value_if_file_not_found == false
    value_if_file_not_found
  end
end
