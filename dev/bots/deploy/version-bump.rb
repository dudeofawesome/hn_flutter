#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.setup(:default, :ci)
require 'git'
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
    options.allow_dirty = false
    options.commit = true
    options.commit_changelog = false
    options.tag = true
    options.push = true
    options.version = nil
    options.auto_accept = false

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

      opts.on('--[no-]allow-dirty', 'Whether to allow running on a dirty repo') do |allow_dirty|
        options.allow_dirty = allow_dirty
      end

      opts.on('--[no-]commit-cl', 'Whether to commit changelog changes with too') do |commit_changelog|
        options.commit_changelog = commit_changelog
        options.allow_dirty = true if commit_changelog
      end

      opts.on('--[no-]commit', 'Whether to commit changes') do |commit|
        options.commit = commit
      end

      opts.on('--[no-]tag', 'Whether to tag commit') do |tag|
        if !options.commit
          puts "Committing must be enabled to tag"
          exit
        end
        options.tag = tag
      end

      opts.on('--[no-]push', 'Whether to push changes') do |push|
        options.push = push
      end

      opts.on('-y', '--yes', 'Automatically answer yes to all prompts') do |auto_accept|
        options.auto_accept = auto_accept
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

def check_if_dirty (options, git)
  status = git.status
  if status.added.size + status.changed.size + status.deleted.size + status.untracked.size > 0
    puts "Repo is dirty"
    exit(1)
  end
end

def add_changelog (options, git)
  begin
    git.add('changelogs/.')
  rescue
    puts "No changelogs found to commit"
  end
end

def commit_changes (options, git)
  git.add([options.pubspec_path, options.android_build_gradle_path])
  git.commit("🚀🔖 v#{options.version}")
end

def tag_commit (options, git)
  git.add_tag("v#{options.version}", :options => 'here')
end

def push_origin (git)
  git.push('origin', git.current_branch, :tags => true)
end

def get_current_version (options)
  pubspec = YAML.load_file(options.pubspec_path)
  version_string = pubspec['version']
  version = Semverse::Version.new(version_string)
  version
end

def bump_version (options)
  major = options.version.major
  minor = options.version.minor
  patch = options.version.patch
  pre_release = options.version.pre_release
  build = options.version.build

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
  when 'pre_release' 'prerelease', 'pre'
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

def write_version_to_files (options)
  write_version_to_pubspec(options)
  write_version_to_android(options)
end

def write_version_to_pubspec (options)
  File.open(options.pubspec_path, 'r') { |f|
    curr = f.read()
    f.close()
    File.open(options.pubspec_path, 'w') { |f|
      f.write(
        curr.gsub(/^(\s*version:\s*)\d+(?:\.\d+){2,2}(?:\w|-)*$/m) { |match| "#{$1}#{options.version}"})
      f.close()
    }
  }
end

def write_version_to_android (options)
  File.open(options.android_build_gradle_path, 'r') { |f|
    curr = f.read()
    f.close()
    File.open(options.android_build_gradle_path, 'w') { |f|
      f.write(curr
        .gsub(/^(\s*versionCode\s*)(\d+)$/m) { |match| "#{$1}#{$2.to_i + 1}"}
        .gsub(/^(\s*versionName\s*)".*?"$/m) { |match| "#{$1}\"#{options.version}\""})
      f.close()
    }
  }
end

options = VersionBump.parse(ARGV)
git = Git.open("#{__dir__}/../../../")

check_if_dirty(options, git) unless options.allow_dirty

if options.version == nil
  options.version = get_current_version(options)
  options.version = bump_version(options)
end
if !options.auto_accept
  puts "Bump to #{options.version}? (yes)"
  exit 1 if (gets.chomp || '').downcase == 'no'
end
puts "Bumping to #{options.version}"
write_version_to_files(options)

add_changelog(options, git) if options.commit_changelog
commit_changes(options, git) if options.commit
tag_commit(options, git) if options.tag
push_origin(git) if options.push
