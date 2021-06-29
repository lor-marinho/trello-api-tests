# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'httparty'
require 'awesome_print'
require "addressable/uri"
require "http"
require 'pry-byebug'

def app_key
    ENV.fetch('TRELLO_APP_KEY')
end

def app_token
    ENV.fetch('TRELLO_APP_TOKEN')
end

def trello_url(path, params = {})
  auth_params = { key: app_key, token: app_token }

  Addressable::URI.new({
    scheme: "https",
    host: "api.trello.com",
    path: File.join("1", path),
    query_values: auth_params.merge(params)
  })
end




# url = "https://api.trello.com/1/members/me?key=#{api_key}&token=#{api_token}"

    # response = HTTParty.get(trello_url(path))
    # response_body = JSON.parse(response.body)

def get(path)
    HTTP.get(trello_url(path)).parse
end

MAX = 1000

def paginated_get(path, options = {})
  Enumerator.new do |y|
    params  = options.dup
    before  = nil
    total   = 0
    limit   = params.delete(:limit) { 50 }

    loop do
      data = get(path, { before: before, limit: limit }.merge(params))
      total += data.length

      data.each do |element|
        y.yield element
      end

      break if (data.empty? || total >= MAX)

      before = data.last["id"]
    end
  end
end

puts paginated_get("members/me/actions", filter: "commentCard")



# ap response_body

# puts get
