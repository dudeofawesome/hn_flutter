#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.setup(:default, :ci)
require 'base64'
require 'dedent'
require 'git'
require 'json'
require 'net/http'
require 'uri'

repo = 'hn_flutter'
owner = 'dudeofawesome'

if (ENV['GITHUB_OAUTH_TOKEN'] == nil)
  puts "GITHUB_OAUTH_TOKEN must be set in env"
  exit 1
end

git = Git.open("#{__dir__}/../../../")

git_tags = git.tags
git_tag = nil

if ARGV[0] == nil
  last_commit = git.log(1)[0]
  git_tags.each { |t| git_tag = t if t.sha == last_commit.sha }
else
  git_tags.each { |t| git_tag = t if t.sha == ARGV[0] }
end

if (git_tag == nil)
  puts "Error: Latest commit is not tagged"
  exit 1
end


github_api = Net::HTTP.new('api.github.com', 443)
github_api.use_ssl = true
headers = {
  'Content-Type': 'application/json',
  Authorization: "token #{ENV['GITHUB_OAUTH_TOKEN']}",
}

get_release_path = "/repos/#{owner}/#{repo}/releases/tags/#{git_tag.name}"
req = Net::HTTP::Get.new(get_release_path, headers)
res = github_api.request(req)

req = nil
if res.code.to_i >= 200 && res.code.to_i < 300
  puts "Updating release for #{git_tag.name}"
  req = Net::HTTP::Patch.new("/repos/#{owner}/#{repo}/releases/#{JSON.parse(res.body)['id']}", headers)
else
  puts "Creating release for #{git_tag.name}"
  req = Net::HTTP::Post.new("/repos/#{owner}/#{repo}/releases", headers)
end

body = {
  tag_name: git_tag.name,
  target_commitish: "master",
  name: git_tag.name,
  body: %{
    <a href='https://play.google.com/store/apps/details?id=io.orleans.hnflutter'><img alt='Get it on Google Play' height='65px' src='https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png'/></a>

    TODO: INSERT CHANGELOG HERE
  }.gsub(/^\s*\n/, '').gsub(/\n\s*$/, '').dedent,
  draft: false,
  # TODO: get this from semver
  prerelease: true,
}
req.body = body.to_json

res = github_api.request(req)
if res.code.to_i < 200 || res.code.to_i >= 300
  puts "Error creating release (response code #{res.code})"
  exit 1
end

puts "Release set"

upload_url = JSON.parse(res.body)['upload_url'].partition('{?name,label}')[0]

create_release_url = URI.parse("#{upload_url}?name=android-release.apk")
headers = {
  'Content-Type': 'application/zip',
  Authorization: "token #{ENV['GITHUB_OAUTH_TOKEN']}",
}
apk_path = 'build/app/outputs/apk/release/app-release.apk'
apk_file = open(apk_path)
github_upload_api = Net::HTTP.new(create_release_url.host, create_release_url.port)
github_upload_api.use_ssl = create_release_url.scheme == 'https'
req = Net::HTTP::Post.new(create_release_url.request_uri, headers)
req.body = apk_file.read
apk_file.close()

res = github_upload_api.request(req)

puts "Uploaded Android APK"
