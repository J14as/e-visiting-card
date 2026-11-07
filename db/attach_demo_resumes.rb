require_relative "../config/environment"
require "prawn"

# 1. Create a clean sample resume PDF for demo cards
sample_resume_path = Rails.root.join("tmp", "Alex_Sterling_Resume.pdf")
Prawn::Document.generate(sample_resume_path.to_s, page_size: "A4", margin: 40) do |pdf|
  pdf.fill_color "0F172A"
  pdf.font("Helvetica", style: :bold, size: 24)
  pdf.text "Alex Sterling"
  pdf.move_down 4

  pdf.fill_color "4338CA"
  pdf.font("Helvetica", style: :bold, size: 12)
  pdf.text "Principal Cloud Architect & Fractional CTO"
  pdf.move_down 10

  pdf.fill_color "64748B"
  pdf.font("Helvetica", size: 9)
  pdf.text "alex@nexussystems.io  •  +1 (555) 234-5678  •  https://alexsterling.dev  •  San Francisco, CA"
  pdf.move_down 16
  pdf.stroke_color "E2E8F0"
  pdf.stroke_horizontal_rule
  pdf.move_down 16

  pdf.fill_color "0F172A"
  pdf.font("Helvetica", style: :bold, size: 14)
  pdf.text "Executive Summary"
  pdf.move_down 6
  pdf.fill_color "334155"
  pdf.font("Helvetica", size: 10)
  pdf.text "Senior cloud and software architect with 12+ years of experience engineering mission-critical distributed systems, Kubernetes platforms, and Ruby on Rails SaaS architectures. Led engineering organizations through multiple scale phases from zero to millions of daily active users.", leading: 3
  pdf.move_down 16

  pdf.fill_color "0F172A"
  pdf.font("Helvetica", style: :bold, size: 14)
  pdf.text "Core Expertise & Skills"
  pdf.move_down 6
  pdf.fill_color "334155"
  pdf.font("Helvetica", size: 10)
  pdf.text "• Architecture: Distributed Systems, High Availability, Microservices, Event-Driven Systems\n• Technologies: Ruby on Rails 8, PostgreSQL, Redis, Kubernetes, AWS, Terraform, Docker\n• Leadership: Team Scaling, Engineering Strategy, Technical Hiring, Agile Delivery", leading: 3
  pdf.move_down 16

  pdf.fill_color "0F172A"
  pdf.font("Helvetica", style: :bold, size: 14)
  pdf.text "Professional Experience"
  pdf.move_down 6
  pdf.font("Helvetica", style: :bold, size: 11)
  pdf.text "Principal Cloud Architect — Nexus Systems & SaaS Labs (2021 – Present)"
  pdf.font("Helvetica", size: 9.5)
  pdf.fill_color "475569"
  pdf.text "Architected high-throughput infrastructure processing 50M+ requests/day at 99.99% uptime.\nAutomated zero-downtime multi-region deployments with Kubernetes & Terraform.", leading: 2
end

puts "Sample resume generated at #{sample_resume_path} (size: #{File.size(sample_resume_path)} bytes)"

# 2. Attach to demo cards
["alex-sterling", "sterling-consulting", "alex-cyber"].each do |slug|
  card = VisitingCard.find_by(slug: slug)
  if card
    card.resume.attach(
      io: File.open(sample_resume_path),
      filename: "#{card.full_name.parameterize}-resume.pdf",
      content_type: "application/pdf"
    )
    puts "Attached sample resume to #{card.slug}: has_resume? = #{card.has_resume?}"
  end
end

puts "Done! All demo cards now have verified sample resumes."

