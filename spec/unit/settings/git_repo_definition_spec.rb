require 'spec_helper'
require 'r10k/settings/git_repo_definition'

describe R10K::Settings::GitRepoDefinition do
  subject { described_class.new(:gitrepo) }

  describe "validating the URL field" do
    it "raises an error when the URL is not set" do
      subject.assign({})
      expect {
        subject.validate
      }.to raise_error(ArgumentError, "Git repository URL must be set")
    end

    it "raises an error when the URL is not a string" do
      subject.assign(url: 12345)
      expect {
        subject.validate
      }.to raise_error(ArgumentError, "Git repository URL must be a String, not a Fixnum")
    end

    it "accepts a valid http URL" do
      subject.assign(url: "http://tessier-ashpool.freeside/repo.git")
      subject.validate
    end

    it "accepts a valid SSH URL with an explicit SSH schema" do
      subject.assign(url: "ssh://git@tessier-ashpool.freeside:repo.git")
      subject.validate
    end

    it "accepts a valid SSH URL with an explicit SSH schema" do
      subject.assign(url: "git@tessier-ashpool.freeside:repo.git")
      subject.validate
    end
  end

  describe "validating the private key" do
    it "raises an error when the private key is set and not a string" do
      subject.assign(url: 'https://tessier-ashpool.freeside/repo.git', private_key: false)
      expect {
        subject.validate
      }.to raise_error(ArgumentError, "Git repository SSH private key must be a String when set, not a FalseClass")
    end

    it "accepts a valid private key" do
      subject.assign(url: 'ssh://tessier-ashpool.freeside/repo.git', private_key: '/etc/puppetlabs/r10k/id_rsa')
      subject.validate
    end
  end
end
