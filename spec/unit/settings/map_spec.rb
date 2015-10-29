require 'spec_helper'
require 'r10k/settings/map'
require 'r10k/settings/definition'

describe R10K::Settings::Map do
  describe "assigning values" do
    subject do
      described_class.new(:map) do |key, value|
        R10K::Settings::Definition.new("key-#{key}").tap do |d|
          d.assign("value-#{value}")
        end
      end
    end

    it "calls the supplied block to create each nested setting" do
      subject.assign(first: "un", second: "deux")
      result = subject.resolve
      expect(result).to eq("key-first" => "value-un", "key-second" => "value-deux")
    end
  end
end
