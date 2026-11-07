class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if user_signed_in?
    # Sample demo card data for live landing page illustration
    @demo_card = VisitingCard.new(
      full_name: "Alex Sterling",
      designation: "Principal Cloud Architect",
      company_or_tagline: "Nexus Systems & SaaS Labs",
      bio: "Building high-performance distributed systems, scalable web apps, and modern developer infrastructure. Passionate about Open Source and cloud-native solutions.",
      phone: "+1 (555) 948-2910",
      email: "alex@nexussystems.io",
      portfolio_url: "https://alexsterling.dev",
      linkedin_url: "https://linkedin.com/in/alexsterling",
      github_url: "https://github.com/alexsterling",
      instagram_url: "https://instagram.com/alexsterling",
      template_style: "modern_dark",
      color_theme: "indigo",
      slug: "alex-sterling"
    )
  end
end

