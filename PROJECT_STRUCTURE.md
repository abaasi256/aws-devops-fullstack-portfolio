# Project Structure and File Guide

## 📁 Repository Structure

```
aws-devops-fullstack-portfolio/
├── README.md                    # Main project documentation
├── LICENSE                      # MIT License
├── .gitignore                  # Git ignore rules
├── .github/                    # GitHub Actions workflows
│   └── workflows/
│       ├── deploy.yml          # Full CI/CD deployment (requires secrets)
│       └── build-only.yml      # Build and test only (free tier friendly)
├── backend/                    # Node.js/Express API
│   ├── package.json           # Backend dependencies
│   ├── server.js              # Main server file
│   ├── .env.example           # Environment variables template
│   └── src/                   # Source code
│       ├── routes/            # API routes
│       ├── models/            # Data models
│       ├── middlewares/       # Express middlewares
│       └── utils/             # Utility functions
├── frontend/                   # React.js application
│   ├── package.json           # Frontend dependencies
│   ├── public/                # Static assets
│   └── src/                   # React source code
│       ├── components/        # React components
│       ├── pages/             # Page components
│       ├── context/           # React context
│       └── utils/             # Frontend utilities
├── infra/                     # Terraform infrastructure
│   ├── main.tf               # Main infrastructure definition
│   ├── variables.tf           # Variable definitions
│   ├── outputs.tf             # Output values
│   ├── terraform.tfvars.example # Configuration template
│   └── modules/               # Reusable Terraform modules
│       ├── networking/        # VPC, subnets, gateways
│       ├── security/          # Security groups, IAM roles
│       ├── compute/           # EC2, ASG, ALB, bastion host
│       ├── database/          # RDS Aurora cluster
│       └── monitoring/        # CloudWatch, alarms, dashboards
├── docs/                      # Documentation
│   ├── deployment.md          # Deployment guide
│   ├── architecture.md        # Architecture overview
│   ├── architecture.svg       # Architecture diagram
│   └── images/               # Documentation images
├── ci/                       # CI/CD configurations
│   ├── README.md             # CI/CD documentation
│   └── aws/                  # AWS CodePipeline configs
│       ├── buildspec.yml     # CodeBuild specification
│       ├── appspec.yml       # CodeDeploy specification
│       └── scripts/          # Deployment scripts
└── monitoring/               # Monitoring configurations
    ├── README.md             # Monitoring documentation
    ├── cloudwatch-agent-config.json
    ├── cloudwatch-dashboard.yml
    └── setup-monitoring.sh
```

## 🚀 Quick Start

1. **Clone and configure:**
   ```bash
   git clone <your-repo-url>
   cd aws-devops-fullstack-portfolio
   cp infra/terraform.tfvars.example infra/terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

2. **Deploy infrastructure:**
   ```bash
   cd infra
   terraform init && terraform apply
   ```

3. **Deploy application:**
   Follow deployment guide in `docs/deployment.md`

## 📚 Key Documentation

- **[README.md](README.md)** - Main project overview and quick start
- **[docs/deployment.md](docs/deployment.md)** - Detailed deployment instructions
- **[docs/architecture.md](docs/architecture.md)** - System architecture and design decisions
- **[ci/README.md](ci/README.md)** - CI/CD pipeline setup and configuration
- **[monitoring/README.md](monitoring/README.md)** - Monitoring and alerting setup

## 🔧 Development Workflow

1. **Local development:** Run frontend and backend locally for development
2. **Infrastructure changes:** Modify Terraform files and apply changes
3. **Application changes:** Update code and deploy via preferred method
4. **Documentation:** Keep docs updated with any significant changes

## 🛡️ Security Notes

- **Sensitive files excluded:** `.gitignore` prevents committing sensitive data
- **SSH keys:** Store securely, never commit to repository
- **Environment variables:** Use `.env.example` as template, never commit actual `.env`
- **AWS credentials:** Configure locally, use IAM roles in production

## 📖 Portfolio Value

This project demonstrates:
- **Infrastructure as Code** with Terraform
- **Cloud architecture** with AWS services
- **Security best practices** with VPC, security groups, IAM
- **CI/CD pipelines** with GitHub Actions
- **Monitoring and alerting** with CloudWatch
- **Documentation** and project organization
- **Full-stack development** with React and Node.js
