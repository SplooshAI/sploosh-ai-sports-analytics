#!/bin/bash

# Configuration
BOT_NAME="github-actions[bot]"
BOT_EMAIL="41898282+github-actions[bot]@users.noreply.github.com"
KEY_COMMENT="GitHub Actions bot (SplooshAI)"

PASSPHRASE="d3f3nd!t"
# # Prompt for passphrase
# echo "Enter passphrase for new GPG key:"
# read -s PASSPHRASE
# echo "Confirm passphrase:"
# read -s PASSPHRASE_CONFIRM

# if [ "$PASSPHRASE" != "$PASSPHRASE_CONFIRM" ]; then
#     echo "Error: Passphrases do not match"
#     exit 1
# fi

# if [ -z "$PASSPHRASE" ]; then
#     echo "Error: Passphrase cannot be empty"
#     exit 1
# fi

# Generate GPG key configuration file
cat > gpg-key-config <<EOF
%echo Generating GPG key for GitHub Actions
Key-Type: RSA
Key-Length: 4096
Key-Usage: sign
Subkey-Type: RSA
Subkey-Length: 4096
Subkey-Usage: encrypt
Name-Real: $BOT_NAME
Name-Comment: $KEY_COMMENT
Name-Email: $BOT_EMAIL
Expire-Date: 0
Passphrase: $PASSPHRASE
%commit
%echo Done
EOF

# Generate key
gpg --batch --generate-key gpg-key-config

# Export public key
KEY_ID=$(gpg --list-secret-keys --keyid-format LONG "$BOT_EMAIL" | grep sec | awk '{print $2}' | cut -d'/' -f2)
echo -e "\nPublic Key:"
gpg --armor --export $KEY_ID

# Export private key (for GitHub secret)
echo -e "\nPrivate Key (for GitHub secret):"
gpg --armor --export-secret-key $KEY_ID

# Cleanup
rm gpg-key-config

echo -e "\nKey generation complete!"
echo "Key ID: $KEY_ID"
echo "Email: $BOT_EMAIL"
echo "Remember to store the passphrase securely - you'll need it for the GPG_PASSPHRASE secret in GitHub" 