require 'spec_helper'

describe JIRA::Resource::Project do

  let(:client) { double("client", :options => {
                          :rest_base_path => '/jira/rest/api/2'
                        })
  }

  describe "relationships" do
    subject {
      JIRA::Resource::Project.new(client, :attrs => {
          'lead'        => {'foo' => 'bar'},
          'issueTypes'  => [{'foo' =>'bar'},{'baz' => 'flum'}],
          'versions'    => [{'foo' =>'bar'},{'baz' => 'flum'}],
      })
    }

    it "has the correct relationships" do
      expect(subject).to have_one(:lead, JIRA::Resource::User)
      expect(subject.lead.foo).to eq('bar')

      expect(subject).to have_many(:issuetypes, JIRA::Resource::Issuetype)
      expect(subject.issuetypes.length).to eq(2)

      expect(subject).to have_many(:versions, JIRA::Resource::Version)
      expect(subject.versions.length).to eq(2)
    end
  end

  describe "issues" do
    subject {
      JIRA::Resource::Project.new(client, :attrs => {
          'key'         => 'test'
        })
    }

    it "returns issues" do
      response_body = '{"expand":"schema,names","startAt":0,"maxResults":1,"total":1,"issues":[{"expand":"editmeta,renderedFields,transitions,changelog,operations","id":"53062","self":"/rest/api/2/issue/53062","key":"test key","fields":{"summary":"test summary"}}]}'
      response = double("response",
        :body => response_body)
      issue_factory = double("issue factory")

      expect(client).to receive(:get)
        .with('/jira/rest/api/2/search?jql=project%3D%22test%22')
        .and_return(response)
      expect(client).to receive(:Issue).and_return(issue_factory)
      expect(issue_factory).to receive(:build)
        .with(JSON.parse(response_body)["issues"][0])
      subject.issues
    end

    context "with changelog" do
      it "returns issues" do
        response_body = '{"expand":"schema,names","startAt":0,"maxResults":1,"total":1,"issues":[{"expand":"editmeta,renderedFields,transitions,changelog,operations","id":"53062","self":"/rest/api/2/issue/53062","key":"test key","fields":{"summary":"test summary"},"changelog":{}}]}'
        response = double("response",
          :body => response_body)
        issue_factory = double("issue factory")

        expect(client).to receive(:get)
          .with('/jira/rest/api/2/search?jql=project%3D%22test%22&expand=changelog&startAt=1&maxResults=100')
          .and_return(response)
        expect(client).to receive(:Issue).and_return(issue_factory)
        expect(issue_factory).to receive(:build)
          .with(JSON.parse(response_body)["issues"][0])
        subject.issues({expand:'changelog', startAt:1, maxResults:100})
      end
    end
  end
end
