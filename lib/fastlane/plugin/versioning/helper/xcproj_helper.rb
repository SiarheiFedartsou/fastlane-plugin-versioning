require 'json'
require 'pathname'
require 'strscan'

module Fastlane
  module Helper
    module Xcproj
      PROJECT_FILE_NAME = "project.xcproj".freeze
      STRING = /"(?:[^"\\]|\\.)*"/m
      IGNORED = %r{(?:\s+|//[^\n]*|/\*.*?\*/)+}m

      class Document
        attr_reader :path, :text, :data

        def initialize(path)
          @path = path
          @text = File.read(path)
          @data = JSON.parse(Xcproj.to_json(@text))
          @spans = Xcproj.spans(@text)
        end

        def save
          File.write(path, text)
        end

        def set(object_path, key, value)
          object = object_path.reduce(data) { |node, k| node[k] }
          literal = value.kind_of?(Hash) ? "{}" : JSON.generate(value)
          if (span = @spans[object_path + [key]])
            replace(span[0], span[1], literal)
          else
            insert_member(object_path, object, key, literal)
          end
          object[key] = value
        end

        private

        def replace(start, finish, string)
          @text = @text.byteslice(0, start) + string + @text.byteslice(finish..)
          @spans = Xcproj.spans(@text)
        end

        def insert(offset, string)
          @text = @text.byteslice(0, offset) + string + @text.byteslice(offset..)
        end

        def indentation(offset)
          line_start = (@text.byteslice(0, offset).b.rindex("\n") || -1) + 1
          prefix = @text.byteslice(line_start, offset - line_start)
          [prefix[/\A[ \t]*/], line_start, prefix.strip.empty?]
        end

        def insert_member(object_path, object, key, literal)
          start, finish = @spans[object_path]
          entry = "#{JSON.generate(key)}: #{literal}"
          indent, = indentation(start)
          return replace(start, finish, "{\n#{indent}  #{entry},\n#{indent}}") if object.empty?

          _, last_finish, last_key_start = @spans[object_path + [object.keys.last]]
          child_indent, = indentation(last_key_start)
          _, close_line_start, close_on_own_line = indentation(finish - 1)
          scanner = StringScanner.new(@text.b)
          scanner.pos = last_finish
          scanner.skip(IGNORED)
          comma_at = scanner.peek(1) == "," ? scanner.pos : nil

          if @text.byteslice(start, finish - start).include?("\n") && close_on_own_line
            insert(close_line_start, "#{child_indent}#{entry},\n")
            insert(last_finish, ",") unless comma_at
          elsif comma_at
            insert(comma_at + 1, " #{entry},")
          else
            insert(last_finish, ", #{entry}")
          end
          @spans = Xcproj.spans(@text)
        end
      end

      def self.resolve_path(path = nil)
        return Dir["*.xcodeproj/#{PROJECT_FILE_NAME}"].first || Dir["*.xcproj"].first if path.nil? || path.to_s.empty?

        path = path.to_s
        File.directory?(path) ? File.join(path, PROJECT_FILE_NAME) : path
      end

      def self.open(path)
        file = resolve_path(path)
        UI.user_error!("Could not find project.xcproj at path '#{path}'") if file.nil? || !File.file?(file)

        Document.new(file)
      rescue JSON::ParserError => e
        UI.user_error!("Cannot parse #{file}: #{e.message}")
      end

      def self.to_json(text)
        text
          .gsub(%r{(#{STRING})|//[^\n]*|/\*.*?\*/}m) { Regexp.last_match(1) || "" }
          .gsub(/(#{STRING})|,(?=\s*[}\]])/m) { Regexp.last_match(1) || "" }
      end

      def self.spans(text)
        scanner = StringScanner.new(text.b)
        spans = {}
        read_value = lambda do |path, key_start|
          scanner.skip(IGNORED)
          start = scanner.pos
          if scanner.skip(/\{/)
            until scanner.skip(/#{IGNORED}?\}/)
              scanner.skip(IGNORED)
              member_start = scanner.pos
              key = JSON.parse(scanner.scan(STRING) || raise(JSON::ParserError, "Expected a key at byte #{scanner.pos}"))
              scanner.skip(/#{IGNORED}?:/)
              read_value.call(path + [key.force_encoding(Encoding::UTF_8)], member_start)
              scanner.skip(/#{IGNORED}?,/)
            end
          elsif scanner.skip(/\[/)
            index = 0
            until scanner.skip(/#{IGNORED}?\]/)
              read_value.call(path + [index], nil)
              index += 1
              scanner.skip(/#{IGNORED}?,/)
            end
          else
            scanner.scan(STRING) || scanner.scan(/[^\s,\]}]+/) || raise(JSON::ParserError, "Unexpected character at byte #{scanner.pos}")
          end
          spans[path] = [start, scanner.pos, key_start]
        end
        read_value.call([], nil)
        spans
      end

      def self.enabled?(params)
        return params[:json_format] unless params.respond_to?(:all_keys)

        params.all_keys.include?(:json_format) && params[:json_format]
      end

      class Project
        APPLICATION_PRODUCT_TYPE = "com.apple.product-type.application".freeze
        PRODUCT_TYPE_PREFIX = "com.apple.product-type.".freeze

        def self.open(path)
          new(Xcproj.open(path))
        end

        def initialize(doc)
          @doc = doc
          @changes = {}
        end

        def data
          @doc.data
        end

        def path
          Pathname.new(File.dirname(@doc.path))
        end

        def targets
          @targets ||= Array(data["targets"]).map { |t| Target.new(self, t) }
        end

        def build_configurations
          @build_configurations ||= configuration_names.map { |name| BuildConfiguration.new(self, nil, name) }
        end

        def objects
          build_configurations + targets.flat_map(&:build_configurations)
        end

        def build_settings(configuration_name = nil, key: nil)
          return setting(@scheme_target, key, @scheme_configuration) if key

          keys = (data["build-settings"] || {}).keys.map { |k| k.sub(/\[.*\z/, "") }.uniq
          keys.to_h { |k| [k, setting(nil, k, configuration_name)] }
        end

        def select_scheme(scheme, configuration)
          if scheme.nil?
            @scheme_target = targets.detect { |t| t.product_type == APPLICATION_PRODUCT_TYPE } || targets[0]
            @scheme_configuration = configuration
            return
          end

          UI.user_error!("Cannot find scheme '#{scheme}' next to #{path}") if Xcproj.scheme_path(path, scheme).nil?
          scheme_targets = Xcproj.scheme_target_names(path, scheme).map { |name| targets.detect { |t| t.name == name } }.compact
          UI.user_error!("Cannot find any target of scheme '#{scheme}' in #{path}") if scheme_targets.empty?

          @scheme_target = scheme_targets.detect { |t| t.product_type == APPLICATION_PRODUCT_TYPE } || scheme_targets[0]
          @scheme_configuration = configuration || Xcproj.scheme_launch_configuration(path, scheme) || data["default-configuration"]
        end

        def save
          @changes.each do |(target, key), values|
            if values.keys.sort == configuration_names.sort && values.values.uniq.count == 1
              write(target, key, values.values.first)
            else
              values.each { |configuration, value| write(target, key, value, configuration) }
            end
          end
          @changes = {}
          @doc.save
        end

        def configuration_names
          names = Array(data["configurations"]).map { |c| c.kind_of?(Hash) ? c["name"] : c }.compact
          names.empty? ? [data["default-configuration"]].compact : names
        end

        def setting(target, key, configuration)
          settings = (target.nil? ? data : target.data)["build-settings"] || {}
          value = settings["#{key}[config=#{configuration}]"] if configuration
          value = settings[key] if value.nil?
          value.kind_of?(Array) ? value.join(" ") : value
        end

        def change(target, key, configuration, value)
          (@changes[[target, key]] ||= {})[configuration] = value
        end

        private

        def write(target, key, value, configuration = nil)
          object = target.nil? ? data : target.data
          object_path = target.nil? ? [] : ["targets", data["targets"].index { |t| t.equal?(target.data) }]
          @doc.set(object_path, "build-settings", {}) unless object["build-settings"].kind_of?(Hash)

          if configuration
            keys = ["#{key}[config=#{configuration}]"]
          else
            keys = object["build-settings"].keys.select { |k| k == key || k.start_with?("#{key}[") }
            keys = [key] if keys.empty?
          end
          keys.each { |k| @doc.set(object_path + ["build-settings"], k, value) }
        end
      end

      class Target
        attr_reader :data

        def initialize(project, data)
          @project = project
          @data = data
        end

        def name
          data["name"]
        end

        def product_type
          data["full-product-type"] || (data["product-type"] && Project::PRODUCT_TYPE_PREFIX + data["product-type"])
        end

        def build_configurations
          @build_configurations ||= @project.configuration_names.map { |name| BuildConfiguration.new(@project, self, name) }
        end

        def resolved_build_setting(key, _root_target_settings = true)
          @project.configuration_names.to_h do |name|
            value = @project.setting(self, key, name)
            [name, value.nil? ? @project.setting(nil, key, name) : value]
          end
        end
      end

      class BuildConfiguration
        attr_reader :name

        def initialize(project, target, name)
          @project = project
          @target = target
          @name = name
        end

        def isa
          "XCBuildConfiguration"
        end

        def resolve_build_setting(key)
          @project.setting(@target, key, name)
        end

        def build_settings
          BuildSettings.new(@project, @target, name)
        end
      end

      class BuildSettings
        def initialize(project, target, configuration)
          @project = project
          @target = target
          @configuration = configuration
        end

        def [](key)
          @project.setting(@target, key, @configuration)
        end

        def []=(key, value)
          @project.change(@target, key, @configuration, value)
        end
      end

      def self.scheme_path(project_path, scheme)
        bundle = File.dirname(resolve_path(project_path))
        ([File.join(bundle, "xcshareddata", "xcschemes", "#{scheme}.xcscheme")] +
          Dir[File.join(bundle, "xcuserdata", "*.xcuserdatad", "xcschemes", "#{scheme}.xcscheme")].sort).find { |p| File.file?(p) }
      end

      def self.scheme_target_names(project_path, scheme)
        file = scheme_path(project_path, scheme)
        return [] if file.nil?

        content = File.read(file)
        (content[%r{<BuildAction\b.*?</BuildAction>}m] || content).scan(/BlueprintName\s*=\s*"([^"]*)"/).flatten.uniq
      end

      def self.scheme_launch_configuration(project_path, scheme)
        file = scheme_path(project_path, scheme)
        file && File.read(file)[/<LaunchAction\b[^>]*?buildConfiguration\s*=\s*"([^"]*)"/m, 1]
      end
    end
  end
end
