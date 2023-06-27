# Example of DevSecOps Implementation - Pre-commit Hook with Gitleaks

This is a pre-commit script that includes standard pre-commit functions from GitHub, as well as Gitleaks (https://github.com/gitleaks/gitleaks). It can help you check your commits for trailing whitespace and secrets.

# Installation v1 pre-commit.sh

To use the script, run the following command in the root folder of your GitHub project:
   ```
   curl -sSL  https://raw.githubusercontent.com/evgenpavlyuchek/devsecops/main/pre-commit.sh  | sh
   ```
# Usage v1 pre-commit.sh

The script will automaticly install it in .git/hooks/pre-commit and install Gitleaks, depends of your OS, if you haven't installed it yet. If there are any issues with the installation of Gitleaks within the script, due to the need for additional privileges, you can always install it manually by following the recommendations on the official repository:
   ```
   https://github.com/gitleaks/gitleaks
   ```

Once Gitleaks is installed, you can run the script again, and it will detect the existing Gitleaks installation and show you the results of checking your code.

# Installation v2 pre-commit+interactive.sh

To use the script, run the following command in the root folder of your GitHub project:
   ```
   curl -sSL -o pre-commit+interactive.sh https://raw.githubusercontent.com/evgenpavlyuchek/devsecops/main/pre-commit+interactive.sh
   chmod +x ./pre-commit+interactive.sh
   ```
# Usage v2 pre-commit+interactive.sh 

The script will show you the result of the checks or ask you to install Gitleaks, depends of your OS, if you haven't installed it yet. If there are any issues with the installation of Gitleaks within the script, you can always install it manually by following the recommendations on the official repository:
   ```
   https://github.com/gitleaks/gitleaks
   ```

Once Gitleaks is installed, you can run the script again, and it will detect the existing Gitleaks installation and show you the results of checking your code.

After displaying the results, the script will ask if you want to install it in .git/hooks/pre-commit for automatic use during making commits. However, you can also cancel the installation if desired.

# .git/hooks/pre-commit

After installation in .git/hooks/pre-commit, whenever you make a commit in your repository, the pre-commit hook script will be executed. It will run Gitleaks to check for secrets and also check trailing whitespace. If any errors are found, the commit will be rejected; otherwise, the commit will proceed.

# Requirements

The script can be run on Linux, macOS, or Windows using Git Bash. The installation has been tested on Linux and Windows, but it may require additional privileges.

Remember to review any scripts before executing them.

# Parameters

The script has two parameters. Use the following commands to enable or disable checking for secrets and trailing whitespace:

   ```
   git config hooks.gitleaks true
   git config hooks.gitleaks false
   ```

   ```
   git config hooks.whitespace true
   git config hooks.whitespace false
   ```