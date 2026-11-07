# Seed demo user and sample visiting cards
puts "Creating demo user..."
demo_user = User.find_or_create_by!(email: "demo@cardforge.io") do |u|
  u.name = "Alex Sterling"
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "Creating sample visiting cards..."

# Card 1: Modern Dark - Tech & Architecture
VisitingCard.find_or_create_by!(slug: "alex-sterling") do |card|
  card.user = demo_user
  card.card_title = "Corporate Architecture Card"
  card.full_name = "Alex Sterling"
  card.designation = "Principal Cloud Architect"
  card.company_or_tagline = "Nexus Systems & SaaS Labs"
  card.bio = "Designing fault-tolerant distributed cloud infrastructure, microservices, and developer-first SaaS products. Passionate about Kubernetes, Rails 8, and open source."
  card.phone = "+1 (555) 234-5678"
  card.email = "alex@nexussystems.io"
  card.portfolio_url = "https://alexsterling.dev"
  card.linkedin_url = "https://linkedin.com/in/alexsterling"
  card.github_url = "https://github.com/alexsterling"
  card.instagram_url = "https://instagram.com/alexsterling"
  card.template_style = "modern_dark"
  card.color_theme = "indigo"
  card.views_count = 142
end

# Card 2: Clean Light - Consulting & Advisory
VisitingCard.find_or_create_by!(slug: "sterling-consulting") do |card|
  card.user = demo_user
  card.card_title = "Freelance & Advisory Card"
  card.full_name = "Alex Sterling"
  card.designation = "Fractional CTO & Tech Advisor"
  card.company_or_tagline = "Sterling Advisory Partners"
  card.bio = "Advising seed and Series-A founders on technical architecture, hiring engineering leadership, and scaling cloud budgets efficiently."
  card.phone = "+1 (555) 876-5432"
  card.email = "advisor@sterlingadvisory.com"
  card.portfolio_url = "https://sterlingadvisory.com"
  card.linkedin_url = "https://linkedin.com/in/alexsterling"
  card.template_style = "clean_light"
  card.color_theme = "sky"
  card.views_count = 89
end

# Card 3: Cyber Glass - Tech Speaker & Hackathons
VisitingCard.find_or_create_by!(slug: "alex-cyber") do |card|
  card.user = demo_user
  card.card_title = "Conference Speaker Card"
  card.full_name = "Alex Sterling"
  card.designation = "Keynote Speaker & OSS Contributor"
  card.company_or_tagline = "DevConf & WebScale Summit"
  card.bio = "Regular speaker on distributed consensus, Rust, Hotwire, and AI developer tooling. Available for podcasts, workshops, and keynotes."
  card.phone = "+1 (555) 456-7890"
  card.email = "speaker@alexsterling.dev"
  card.portfolio_url = "https://alexsterling.dev/talks"
  card.github_url = "https://github.com/alexsterling"
  card.template_style = "cyber_glass"
  card.color_theme = "emerald"
  card.views_count = 215
end

puts "Seed data successfully loaded!"
puts "Demo credentials:"
puts "  Email: demo@cardforge.io"
puts "  Password: password123"

# Automatically attach sample resumes if not attached
begin
  sample_path = Rails.root.join("tmp", "Alex_Sterling_Resume.pdf")
  if File.exist?(sample_path)
    VisitingCard.where(resume_url: [nil, ""]).each do |card|
      unless card.resume.attached?
        card.resume.attach(
          io: File.open(sample_path),
          filename: "#{card.full_name.parameterize}-resume.pdf",
          content_type: "application/pdf"
        )
      end
    end
  end
rescue => e
  puts "Note on seeding resumes: #{e.message}"
end

