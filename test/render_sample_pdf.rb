require "prawn"

CARD_WIDTH = 252.0
CARD_HEIGHT = 144.0

pdf = Prawn::Document.new(
  page_size: [CARD_WIDTH, CARD_HEIGHT],
  margin: 0
)

puts "Generated PDF:"
puts "Page count: #{pdf.page_count}"
puts "Page 1 size: #{pdf.page.dimensions.inspect}"
puts "Page 1 width: #{pdf.bounds.width}, height: #{pdf.bounds.height}"

pdf.start_new_page(size: [CARD_WIDTH, CARD_HEIGHT], margin: 0)
puts "Page 2 size: #{pdf.page.dimensions.inspect}"
puts "Page 2 width: #{pdf.bounds.width}, height: #{pdf.bounds.height}"

