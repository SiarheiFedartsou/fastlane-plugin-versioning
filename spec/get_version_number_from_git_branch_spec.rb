require 'spec_helper'

describe Fastlane::Actions::GetVersionNumberFromGitBranchAction do
  describe "Get Version Number From Git Branch Integration" do

    it "should return version extracted from git branch name" do
      result = Fastlane::FastFile.new.parse("lane :test do
        get_version_number_from_git_branch
      end").runner.execute(:test)
      expect(result).to eq("1.3.5")
    end

  end
end
