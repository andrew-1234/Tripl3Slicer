require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'pry'

csv_file = './output/clozed_song.csv'
cards = []

CSV.parse(File.read(csv_file), col_sep: ';', skip_lines: '#').each do |row|
  # Extract the three fields from the CSV row
  front, back, other = row

  # Create a JSON structure for the card
  card_json = {
    "deckName": 'portuguese', # Replace with your deck name
    "modelName": 'Cloze', # Replace with your model name
    "fields": {
      "Text": front,
      "Back Extra": back
    },
    "tags": []
  }

  # Add the card JSON to the array
  cards << card_json
end

structure = {
  "action": 'addNotes',
  "version": 6,
  "params": {
    "notes": cards
  }
}

uri = URI.parse('http://localhost:8765')
http = Net::HTTP.new(uri.host, uri.port)

header = { 'Content-Type': 'text/json' }
request = Net::HTTP::Post.new(uri.request_uri, header)
request.body = structure.to_json
response = http.request(request)
puts response.body
