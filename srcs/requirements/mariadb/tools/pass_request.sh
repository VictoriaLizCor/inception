#!/bin/bash

# read -sp "Password: " password
#!/bin/bash

# Request password
echo -n "Password: "
read -s password
echo

# Check password (replace this with your actual authentication logic)
if ! echo "$password" | sudo -S true 2>/dev/null; then
    echo "Authentication failed."
    exit 1
fi

# If authentication is successful, continue with the session
exec "$SHELL"