# 📇 CardForge — Multi-User SaaS Digital Visiting Card & Dynamic QR Platform

CardForge is a modern, production-ready SaaS digital visiting card and dynamic QR code generation platform built with **Ruby on Rails 8**, **PostgreSQL**, **Devise**, **Hotwire (Turbo & Stimulus)**, **Tailwind CSS**, **rqrcode**, and **Prawn**.

Users can register, create multiple digital visiting cards for different roles (corporate, freelance, side projects), customize their visual style in real-time, generate dynamic QR codes, export print-ready PDFs, and share instant 1-tap contact save links (`.vcf` vCards).

---

## 🌟 Key Features

1. **Multi-User SaaS Architecture & Authentication:**
   - Powered by **Devise** with user registration, secure password hashing, and user profile ownership.
   - Multi-card management: each user can create and maintain multiple visiting cards (e.g., Corporate Executive, Freelance Consultant, Tech Speaker).

2. **Real-Time Split Screen Card Builder (`/cards/:id/edit` & `/cards/new`):**
   - Interactive live preview powered by **Stimulus** (`card_preview_controller.js`).
   - Instant visual reflection as users type their Name, Designation, Company, Bio, Phone, Email, and Social links.
   - Interactive flip card toggle allowing users to preview both the **Front Side** and the **Back Side (QR Code)** in real-time.

3. **Resume / CV Provision & Direct Download:**
   - **Upload Resume:** Attach your Resume / CV directly (`.pdf`, `.doc`, `.docx`) powered by Active Storage.
   - **External Resume Link:** Support for linking resumes hosted on Google Drive, Notion, or LinkedIn.
   - **1-Click Download on Public Profile:** Mobile visitors and recruiters can download your resume in one tap via `/c/:slug/resume`.

4. **10 Designer Template Styles & 6 Brand Color Accents:**
   - 🌑 **Modern Dark:** Obsidian background with glowing borders and high contrast.
   - ☀️ **Clean Light:** Crisp white, minimalist layout with subtle soft shadows.
   - ⚪ **Minimalist Mono:** Timeless Swiss editorial monochrome aesthetic.
   - 🌌 **Aurora Mesh:** Vibrant violet & cyan mesh gradient with glassmorphism.
   - 🟢 **Cyber Emerald:** Modern tech aesthetic with emerald accents and dark carbon finish.
   - 📖 **Quiet Editorial:** Warm paper tones and refined typography.
   - 🌿 **Soft Botanical:** A calm, nature-inspired sage palette.
   - 🧱 **Warm Terracotta:** Soft cream and clay tones.
   - 🌙 **Midnight Gold:** Deep blue with restrained gold details.
   - ✨ **Luxe Onyx:** A dramatic onyx design with elegant accents.
   - 🎨 **Color Themes:** Indigo, Emerald, Violet, Sky Blue, Rose, and Amber Gold.

4. **Dynamic Smart QR Code Engine (`rqrcode` & `chunky_png`):**
   - Generates high-contrast, scalable **SVG** and **PNG** QR codes dynamically on the fly.
   - Point any smartphone camera to automatically open the user's mobile profile page.
   - Dedicated SVG and PNG download endpoints.

5. **Smart Mobile-Optimized Public Profile (`/c/:slug`):**
   - Friendly vanity URLs powered by `friendly_id` (e.g. `/c/alex-sterling`).
   - **1-Tap Save Contact:** Instant RFC-compliant `.vcf` vCard download compatible with Apple Contacts (iOS) and Google Contacts (Android).
   - **Direct Action Buttons:** WhatsApp direct chat (`https://wa.me/...`), direct phone dialing (`tel:`), direct email (`mailto:`), and website.
   - Social links: LinkedIn, GitHub, Instagram.
   - Interactive QR Code modal for easy scanning directly off another screen.
   - Privacy-friendly analytics counter tracking total profile views.

6. **High-Resolution Print-Ready Business Card PDF Export:**
   - Built with **Prawn** (`VisitingCardPdfGenerator`).
   - Renders a standard 3.5" x 2.0" (252pt x 144pt) double-sided card with template-specific compositions: centered, split-panel, typographic, tech-grid, botanical, and editorial layouts.
   - Keeps a dedicated QR reverse, quiet zone for scanning, print-safe framing, and the selected brand palette on both sides and the A4 print sheet.

---

## 🏗️ Tech Stack

- **Framework:** Ruby on Rails 8.1.3
- **Language:** Ruby 3.3.4 (via WSL Ubuntu)
- **Database:** PostgreSQL 16
- **Authentication:** Devise 5.0
- **Frontend / Styling:** Tailwind CSS v4 & Hotwire (Turbo + Stimulus)
- **QR Code Generation:** `rqrcode` 3.2 & `chunky_png` 1.4
- **PDF Generation:** `prawn` 2.4 & `prawn-svg`
- **Slugging:** `friendly_id` 5.5

---

## 🚀 Quick Start Guide (Using WSL)

### 1. Prerequisites
Ensure you have WSL (Ubuntu) installed with Ruby 3.3+ and PostgreSQL running:
```bash
# Start PostgreSQL service in WSL if not already running
sudo service postgresql start
```

### 2. Clone / Open Directory in WSL
```bash
cd "/mnt/c/Users/Jayesh/Desktop/E-Visiting Card"
```

### 3. Install Dependencies
```bash
bundle install
```

### 4. Database Setup & Migrations
```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

The seed script creates a demo account with 3 sample visiting cards:
- **Email:** `demo@cardforge.io`
- **Password:** `password123`
- **Sample Cards:**
  - `/c/alex-sterling` (Modern Dark)
  - `/c/sterling-consulting` (Clean Light)
  - `/c/alex-cyber` (Cyber Glass)

### 5. Start the Development Server
```bash
bin/dev
# or standard rails server:
bin/rails server -b 0.0.0.0 -p 3000
```
Open your browser at: [http://localhost:3000](http://localhost:3000)

---

## 🧪 Running the Automated Test Suite

Run the full automated test suite covering models, controllers, validations, QR generation, vCard export, and PDF generation:

```bash
bin/rails test
```

Or run individual test files:
```bash
bin/rails test test/models/visiting_card_test.rb
bin/rails test test/controllers/public_cards_controller_test.rb
bin/rails test test/controllers/cards_controller_test.rb
```

---

## 📁 Key Files & Architecture

```
app/
├── controllers/
│   ├── application_controller.rb       # Devise redirects & browser rules
│   ├── cards_controller.rb             # Card CRUD, PDF & QR download, card duplication
│   ├── dashboard_controller.rb         # User dashboard & analytics
│   ├── pages_controller.rb             # Public SaaS landing page
│   ├── public_cards_controller.rb      # /c/:slug public view, .vcf vcard & PDF downloads
│   └── users/
│       ├── registrations_controller.rb # Custom Devise registration with name field
│       └── sessions_controller.rb      # Custom Devise login
├── models/
│   ├── user.rb                         # Devise User model, has_many :visiting_cards
│   └── visiting_card.rb                # FriendlyId, validations, qr_code_svg/png, to_vcf
├── services/
│   └── visiting_card_pdf_generator.rb  # Prawn 3.5"x2" print-ready double-sided PDF generator
├── javascript/controllers/
│   ├── card_preview_controller.js      # Hotwire Stimulus real-time split screen preview & flip
│   ├── clipboard_controller.js         # 1-click URL & phone copy with visual toast feedback
│   └── modal_controller.js             # Accessible QR code modal overlay
└── views/
    ├── layouts/
    │   ├── application.html.erb        # Main SaaS navigation & flash messages
    │   └── public_card.html.erb        # Lightweight mobile-first public QR profile layout
    ├── pages/home.html.erb             # Public SaaS landing page with live mockup
    ├── dashboard/index.html.erb        # Multi-card management dashboard & analytics
    ├── cards/
    │   ├── new.html.erb                # Split-screen new card builder
    │   ├── edit.html.erb               # Split-screen edit builder & export toolbar
    │   ├── _form.html.erb              # Comprehensive form with real-time Stimulus bindings
    │   └── _preview_card.html.erb      # Interactive live front/back card preview
    └── public_cards/
        └── show.html.erb               # Mobile profile, 1-tap vCard, WhatsApp, PDF & QR modal
```

---

## 🚢 Deployment Guide

### Deploying to Render

1. Create a `render.yaml` or use the Render dashboard to create a **Web Service** and a **PostgreSQL Database**.
2. Set Environment Variables:
   - `DATABASE_URL`: Set to your Render PostgreSQL Internal Connection String.
   - `RAILS_MASTER_KEY`: Your Rails master key from `config/master.key`.
   - `RAILS_ENV`: `production`
3. Build Command:
   ```bash
   bundle install && bin/rails assets:precompile && bin/rails db:migrate
   ```
4. Start Command:
   ```bash
   bin/rails server -b 0.0.0.0 -p $PORT
   ```

### Deploying to Fly.io

1. Authenticate with Fly:
   ```bash
   fly auth login
   ```
2. Launch app:
   ```bash
   fly launch
   ```
3. Attach PostgreSQL database:
   ```bash
   fly postgres attach <your-postgres-app-name>
   ```
4. Deploy:
   ```bash
   fly deploy
   ```

---

## 📄 License
MIT License. Built with Ruby on Rails 8.
