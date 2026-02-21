<h1 align="center" style="border-bottom: none">
  <div>
    <a href="https://foundingdev.com/?utm_source=github&utm_medium=referral&utm_campaign=open_source_repo">
      <br>
    </a>
    FoundingDev
  </div>
</h1>
<h3 align="center">
  Open Source Document Signing & E-Signature Platform
</h3>

<p align="center">
  <strong>Build your own SaaS and save thousands of dollars</strong>
</p>

## About FoundingDev

**FoundingDev's mission is to empower companies to build their own SaaS products and save thousands of dollars** by providing production-ready, open-source alternatives to expensive commercial solutions. Instead of paying premium subscription fees to third-party services, companies can deploy, customize, and control their own infrastructure.

[GoSign](https://gosign.work/?utm_source=github&utm_medium=readme) is a prime example of this philosophy - a fully-featured document signing platform that you can self-host and customize to your exact needs.

## About This Project

[GoSign](https://gosign.work/?utm_source=github&utm_medium=readme) is forked from [DocuSeal](https://github.com/docusealco/docuseal), an excellent open-source document signing platform. We've significantly extended and enhanced the original codebase with enterprise-grade features, transforming it into a production-ready SaaS platform.

### What We've Built

Since forking from DocuSeal, we've added over **1,900+ commits** of enhancements and new features, including:

#### 💳 Complete Stripe Billing & Subscription System
- Full Stripe Checkout integration with promotion codes
- Customer Portal for self-service subscription management
- Webhook handling for all subscription lifecycle events
- Flexible entitlement system supporting both Stripe and manual grants
- Feature restrictions and paywalls based on subscription status
- Idempotent event processing to prevent duplicate charges

#### 📊 Comprehensive Analytics & Tracking
- **Server-side tracking** for Google Analytics 4, Meta (Facebook) Conversions API, Google Ads, X (Twitter), and Customer.io
- **Background job processing** for reliable event delivery
- **UTM attribution tracking** across the entire user journey
- **Click ID capture** (gclid, fbclid, twclid) for accurate conversion attribution
- **PostHog integration** for product analytics
- Full funnel tracking: signup → checkout → subscription → document events

#### 🔐 OAuth/SSO Authentication
- Google OAuth2 integration
- Microsoft OAuth integration
- Password-optional authentication for OAuth users
- Encrypted token storage
- Automatic account creation in multi-tenant mode

#### 🎯 Multi-Tenant SaaS Features
- Self-service registration with OTP email verification
- Per-account subscription and billing management
- Feature restrictions based on subscription tier
- Account-level configuration and branding
- Testing mode for development without Stripe

#### ⏰ Automated Email Reminders
- Configurable reminder schedules (up to 3 reminders per document)
- Flexible intervals from 1 hour to 30 days
- Automatic cascade logic (reminder 2 after reminder 1, etc.)
- Self-scheduling background jobs for reliability
- Per-submitter tracking to prevent duplicate sends

#### 🎨 UI/UX Improvements
- Dark mode support with user preference persistence
- Revamped login and signup pages
- Improved templates and submissions pages
- Redesigned settings interface with conditional visibility
- Better document management UI
- Upgrade prompts for non-subscribed users

#### 💬 Live Chat & Support
- Intercom widget integration
- Automatic user identification
- Available across all pages

#### 📄 Enhanced Document Features
- DOCX/Office document support with automatic PDF conversion
- Bulk submission operations
- Improved export functionality
- Better document processing pipeline

#### 🛠 Development & Deployment
- Docker development environment
- Comprehensive `.env.example` with 200+ configuration options
- Redis integration for background jobs
- Auto-deploy with zero downtime
- Conditional storage configuration (local/S3)

#### 🔒 Security & Performance
- Content Security Policy for all third-party scripts
- Encrypted OAuth tokens
- Webhook signature verification
- Billing cache (2-minute TTL)
- Rate limiting
- Transaction-safe billing operations

## Core Features (Inherited from DocuSeal)

- PDF form fields builder (WYSIWYG)
- 12 field types (Signature, Date, File, Checkbox, etc.)
- Multiple submitters per document
- Automated emails via SMTP
- Files storage on disk, AWS S3, Google Cloud Storage, or Azure
- Automatic PDF eSignature with verification
- Users management
- Mobile-optimized interface
- Multi-language support (7 UI languages, 14 signing languages)
- API and Webhooks for integrations
- Easy deployment in minutes

## Quick Start

### Docker

```sh
docker run --name foundingsign -p 3000:3000 -v.:/data foundingsign/foundingsign
```

### Docker Compose

```sh
curl https://raw.githubusercontent.com/foundingdev/founding-sign/main/docker-compose.yml > docker-compose.yml
docker compose up
```

### Configuration

Copy `.env.example` to `.env` and configure your environment:

```sh
cp .env.example .env
```

Key configurations:
- **Database**: PostgreSQL or MySQL via `DATABASE_URL`
- **Redis**: Required for background jobs
- **Stripe**: For billing and subscriptions
- **SMTP**: For email delivery
- **Storage**: S3, Google Cloud Storage, or Azure
- **OAuth**: Google and Microsoft SSO
- **Analytics**: GA4, Meta, Google Ads, Twitter, Customer.io

See `.env.example` for comprehensive documentation of all 200+ configuration options.

## Feature Restrictions

Control which features require a subscription by setting `RESTRICTED_FEATURES`:

```sh
# Restrict all premium features
RESTRICTED_FEATURES=api,sso,webhooks,email,storage,notifications,esign,personalization,users

# Or pick specific features
RESTRICTED_FEATURES=api,webhooks,sso

# No restrictions (allow everything for free)
RESTRICTED_FEATURES=
```

## Tech Stack

- **Backend**: Ruby on Rails 7.1
- **Database**: PostgreSQL (production), SQLite (development)
- **Background Jobs**: Sidekiq with Redis
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS
- **Payments**: Stripe
- **Storage**: AWS S3, Google Cloud Storage, Azure Blob Storage
- **Analytics**: GA4, Meta CAPI, Google Ads, Customer.io, PostHog
- **Authentication**: Devise + OmniAuth (Google, Microsoft)
- **PDF Processing**: Prawn, HexaPDF

## Why Self-Host?

### Cost Savings
- **DocuSign**: $25-$100/user/month
- **PandaDoc**: $19-$49/user/month
- **HelloSign**: $15-$40/user/month
- **FoundingSign**: $0 (self-hosted) + infrastructure costs (~$20-50/month for small teams)

**Potential savings: $1,200 - $4,800 per year for a 5-person team**

### Benefits
- Full data ownership and control
- No per-user pricing
- Unlimited documents and signatures
- Custom branding and white-label
- HIPAA/GDPR compliance control
- No vendor lock-in
- Full API access without rate limits

## Development

```sh
# Install dependencies
bundle install
yarn install

# Setup database
rails db:setup

# Start Redis
redis-server

# Start Sidekiq
bundle exec sidekiq

# Start Rails server
rails server
```

Visit `http://localhost:3000`

## Deployment

FoundingSign can be deployed to any platform that supports Ruby on Rails:

- Docker (recommended)
- Heroku
- Railway
- Render
- DigitalOcean
- AWS (ECS, EC2, Elastic Beanstalk)
- Google Cloud Run
- Azure App Service

See our deployment guides for platform-specific instructions.

## API & Integrations

FoundingSign provides a comprehensive REST API for:
- Creating and managing templates
- Sending documents for signature
- Retrieving submission status
- Downloading completed documents
- Webhook notifications for all events

API documentation: `/api/docs` (when running)

## Contributing

We welcome contributions! This project is licensed under the AGPLv3, which means:

1. You can use it freely for personal or commercial purposes
2. If you distribute a modified version over a network, you must make your source code available
3. Any modifications must also be licensed under AGPLv3

To contribute:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Distributed under the AGPLv3 License. See [LICENSE](LICENSE) for more information.

This project is a fork of [DocuSeal](https://github.com/docusealco/docuseal) (© 2023 DocuSeal LLC) with significant enhancements and modifications by the FoundingDev team.

## Support

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For questions and community support
- **Website**: [foundingdev.com](https://foundingdev.com/?utm_source=github&utm_medium=referral&utm_campaign=open_source_repo)

## Acknowledgments

Special thanks to the [DocuSeal](https://github.com/docusealco/docuseal) team for creating the excellent foundation that this project is built upon. Their open-source commitment made this possible.

---

**Built with ❤️ by FoundingDev**

*Empowering companies to build their own SaaS and save thousands of dollars*
