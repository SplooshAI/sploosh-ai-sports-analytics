# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please send an email to Rob Brennan at <rob@sploosh.ai>. All security vulnerabilities will be promptly addressed.

Please include the following information in your report:

- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Security Best Practices

When using this project:

1. **API Keys and Credentials**: Never commit API keys, tokens, or credentials to the repository. Use environment variables or secure credential management systems.

2. **Data Privacy**: Be mindful of any personally identifiable information (PII) in downloaded sports data. Follow applicable data protection regulations.

3. **Dependencies**: Keep Node.js and npm updated to the latest LTS versions to receive security patches.

4. **Script Execution**: Review shell scripts before execution, especially when downloading from external sources.

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine the affected versions
2. Audit code to find any similar problems
3. Prepare fixes for all supported versions
4. Release new versions as soon as possible

Thank you for helping keep this project and its users safe!
