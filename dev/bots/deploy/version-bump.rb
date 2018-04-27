#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'semverse'
require 'yaml'

class VersionBump
  def self.parse(args)
    options = OpenStruct.new
    options.pubspec_path = 'pubspec.yaml'
    options.android_build_gradle_path = 'android/app/build.gradle'
    options.pre_release = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: version-bump.rb [major, minor, patch, prerelease] [options]'

      opts.on('--pubspec-path [PATH]', String, 'Path to pubspec') do |path|
        options.pubspec_path = path
      end
      opts.on('--gradle-file-path [PATH]', String, "Path to android's build.gradle") do |path|
        options.android_build_gradle_path = path
      end

      opts.on('-p', '--[no-]pre-release', 'Whether this is a pre-release') do |pre|
        options.pre_release = pre
      end

      opts.on('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options.bump = args.pop || 'patch'
    options
  end
end

options = VersionBump.parse(ARGV)

def get_current_version (options)
  pubspec = YAML.load_file(options.pubspec_path)
  version_string = pubspec['version']
  version = Semverse::Version.new(version_string)
  version
end

def bump_version (options, curr_version)
  major = curr_version.major
  minor = curr_version.minor
  patch = curr_version.patch
  pre_release = curr_version.pre_release
  build = curr_version.build

  case options.bump.downcase
  when 'major'
    major += 1
    minor = 0
    patch = 0
    pre_release = nil
  when 'minor'
    minor += 1
    patch = 0
    pre_release = nil
  when 'patch'
    patch += 1
    pre_release = nil
  when 'pre_release', 'pre'
    pre_release = pre_release.gsub(/(.*?)(\d+)$/) { |match| "#{$1}#{$2.to_i + 1}"}
  else
    puts "Unknown version section #{options.bump}"
    exit(1)
  end

  if options.pre_release
    pre_release = 0
  end

  version = Semverse::Version.new([major, minor, patch, pre_release, build])
end

def write_version_to_files (options, version)
  write_version_to_pubspec(options, version)
  write_version_to_android(options, version)
end

def write_version_to_pubspec (options, version)
  File.open(options.pubspec_path, 'r') { |f|
    curr = f.read()
    f.close()
    File.open(options.pubspec_path, 'w') { |f|
      f.write(
        curr.gsub(/^(\s*version:\s*)\d+(?:\.\d+){2,2}(?:\w|-)*$/m) { |match| "#{$1}#{version}"})
      f.close()
    }
  }
end

def write_version_to_android (options, version)
  File.open(options.android_build_gradle_path, 'r') { |f|
    curr = f.read()
    f.close()
    File.open(options.android_build_gradle_path, 'w') { |f|
      f.write(curr
        .gsub(/^(\s*versionCode\s*)(\d+)$/m) { |match| "#{$1}#{$2.to_i + 1}"}
        .gsub(/^(\s*versionName\s*)".*?"$/m) { |match| "#{$1}\"#{version}\""})
      f.close()
    }
  }
end

version = get_current_version(options)
version = bump_version(options, version)
puts "Bumping to #{version}"
write_version_to_files(options, version)
