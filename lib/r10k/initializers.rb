require 'r10k/logging'

require 'r10k/git'
require 'r10k/git/cache'

require 'r10k/forge/module_release'

module R10K
  module Initializers
    class BaseInitializer

      include R10K::Logging

      def initialize(settings)
        @settings = settings
      end

      private

      def with_setting(key)
        if !@settings[key].nil?
          yield @settings[key]
        end
      end
    end

    class GlobalInitializer < BaseInitializer
      def call
        with_setting(:purgedirs) do |_|
          logger.warn("the purgedirs key in r10k.yaml is deprecated. it is currently ignored.")
        end

        with_setting(:cachedir) { |value| R10K::Git::Cache.settings[:cache_root] = value }

        with_setting(:user) do |value|
          if Process::Sys.uid == 0
            target_uid = Etc.getpwent(value).uid
            Process::Sys.seteuid(target_uid)
          else
            logger.debug "An alternate user #{value} has been supplied but not running as root, ignoring user setting"
          end
        end

        with_setting(:group) do |value|
          if Process::Sys.gid == 0
            target_gid = Etc.getpwent(value).gid
            Process::Sys.setegid(target_gid)
          else
            logger.debug "An alternate group #{value} has been supplied but not running as root, ignoring group setting"
          end
        end

        with_setting(:git) { |value| GitInitializer.new(value).call }
        with_setting(:forge) { |value| ForgeInitializer.new(value).call }
      end
    end

    class GitInitializer < BaseInitializer
      def call
        with_setting(:provider) { |value| R10K::Git.provider = value }
        with_setting(:username) { |value| R10K::Git.settings[:username] = value }
        with_setting(:private_key) { |value| R10K::Git.settings[:private_key] = value }
      end
    end

    class ForgeInitializer < BaseInitializer
      def call
        with_setting(:proxy) { |value| R10K::Forge::ModuleRelease.settings[:proxy] = value }
        with_setting(:baseurl) { |value| R10K::Forge::ModuleRelease.settings[:baseurl] = value }
      end
    end
  end
end
