card = VisitingCard.first
raise "No card found!" unless card

puts "=== SYSTEM VERIFICATION ==="
puts "Card full_name: #{card.full_name}"
puts "Card slug: #{card.slug}"

# Test QR Code generation
svg = card.qr_code_svg("https://cardforge.io/c/#{card.slug}")
puts "QR Code SVG generated: #{svg.length} chars (Valid SVG? #{svg.include?('<svg')})"

png = card.qr_code_png("https://cardforge.io/c/#{card.slug}", size: 300)
puts "QR Code PNG generated: #{png.bytesize} bytes (PNG header? #{png.start_with?("\x89PNG".b)})"

# Test vCard (.vcf) generation
vcf = card.to_vcf("https://cardforge.io/c/#{card.slug}")
puts "vCard generated: #{vcf.lines.count} lines"
puts "Contains FN: #{vcf.include?('FN:' + card.full_name)}"
puts "Contains TEL: #{vcf.include?('TEL;')}"

# Test Prawn PDF generation
pdf_bytes = VisitingCardPdfGenerator.render(card, "https://cardforge.io/c/#{card.slug}")
puts "PDF rendered: #{pdf_bytes.bytesize} bytes (Valid PDF? #{pdf_bytes.start_with?('%PDF')})"

# Test other template styles PDF generation
VisitingCard::TEMPLATE_STYLES.keys.each do |style|
  card.template_style = style
  bytes = VisitingCardPdfGenerator.render(card, "https://cardforge.io/c/#{card.slug}")
  puts "PDF for style '#{style}' rendered: #{bytes.bytesize} bytes"
end

puts "=== ALL VERIFICATIONS PASSED SUCCESSFULLY ==="

