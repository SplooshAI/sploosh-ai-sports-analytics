# Repository Setup

When creating a new repository from this template, follow these configuration steps:

## 1. Configure Workflow Permissions

Go to Settings → Actions → General and configure:

### Workflow Permissions

- Select "Read and write permissions"
- Check "Allow GitHub Actions to create and approve pull requests"
- Click "Save"

### Fork Pull Request Workflows

- Choose whether to run workflows from fork pull requests
- Note: This gives fork maintainers ability to use tokens with read permissions
- Click "Save"

### Access

- Select "Not accessible" if you want to restrict workflow access
- Or "Accessible from repositories in the 'SplooshAI' organization" for org-wide access
- Click "Save"

## 2. Configure Branch Protection

Go to Settings → Branches and add a rule for the `main` branch:

- Require pull request reviews
- Require status checks to pass
- Require signed commits
- Include administrators

## 3. Configure GPG Signing

The repository uses GitHub's native commit verification. All commits, including those from GitHub Actions, must be signed.

1. For manual commits:
   - Contributors should follow the GPG setup guide in [CONTRIBUTING.md](../../CONTRIBUTING.md)

2. For automated commits:
   - GitHub Actions bot is configured to sign commits automatically
   - Uses repository secrets for GPG key and passphrase
   - No additional setup needed for contributors

For more details on commit signing and workflow testing, see:

- [Contributing Guidelines](../../CONTRIBUTING.md)
- [Testing Documentation](./TESTING.md)
