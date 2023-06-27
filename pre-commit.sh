#!/bin/sh
# Pre-commit Hook with Gitleaks
##########################################################################################
#####                            Install                                              ####
##########################################################################################

gitleaksWhere() {
  script_path="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
  hooks_dir="$(basename "$script_path")"
  if [ "$(basename "$hooks_dir")" != "hooks" ]; then
    echo "Installing pre-commit gitleaks..."
    curl -so .git/hooks/pre-commit https://raw.githubusercontent.com/EvgenPavlyuchek/devsecops/main/pre-commit.sh
    chmod +x .git/hooks/pre-commit
    echo "Installed pre-commit gitleaks. You can now use it with 'git commit'."
  fi
}

gitleaksWhere

##########################################################################################
#####                            Install                                              ####
##########################################################################################

mistakes=0

##########################################################################################
#####               almost standart git pre commit check                              ####
##########################################################################################

# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

if git rev-parse --verify HEAD >/dev/null 2>&1
then
	against=HEAD
else
	# Initial commit: diff against an empty tree object
	against=$(git hash-object -t tree /dev/null)
fi

# If you want to allow non-ASCII filenames set this variable to true.
allownonascii=$(git config --type=bool hooks.allownonascii)

# Redirect output to stderr.
exec 1>&2

# Cross platform projects tend to avoid non-ASCII filenames; prevent
# them from being added to the repository. We exploit the fact that the
# printable range starts at the space character and ends with tilde.
if [ "$allownonascii" != "true" ] &&
	# Note that the use of brackets around a tr range is ok here, (it's
	# even required, for portability to Solaris 10's /usr/bin/tr), since
	# the square bracket bytes happen to fall in the designated range.
	test $(git diff --cached --name-only --diff-filter=A -z $against |
	  LC_ALL=C tr -d '[ -~]\0' | wc -c) != 0
then
	cat <<\EOF
Error: Attempt to add a non-ASCII file name.

This can cause problems if you want to work with people on other platforms.

To be portable it is advisable to rename the file.

If you know what you are doing you can disable this check using:

  git config hooks.allownonascii true
EOF
	mistakes=1
fi

# If there are whitespace errors, print the offending file names and fail.
# exec git diff-index --check --cached $against --

echo "=========================================================================================="

#work with git bash, but don't want with ubuntu wsl

if [ "$(git config hooks.whitespace)" = "true" ]; then
  git diff-index --check --cached $against -- | grep -B1 -E '.*[[:blank:]]$'
  output=$(git diff-index --check --cached $against | grep -E '.*[[:blank:]]$')
  count=$(echo "$output" | grep -c -E '.*[[:blank:]]$')
  # $output
  if [ $count -gt 0 ]; then
    mistakes=1
    cat <<EOF
==========================================================================================
Error: Found $count lines with trailing whitespace.
EOF
  else
    echo "Found 0 lines with trailing whitespace."
  fi
else
  echo "Checking whitespace disabled.To enable: git config hooks.whitespace true"
fi

echo "=========================================================================================="

##########################################################################################
#####                            gitleaks                                             ####
##########################################################################################

# Install gitleaks based on the detected OS and architecture
gitleaksInstall() {
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m | tr '[:upper:]' '[:lower:]')
  echo "OS=$os, Arch=$arch"
  case "$os" in
    *mingw*) os="windows" ;;
    *darwin*) os="darwin" ;;
    *linux*) os="linux" ;;
    *) os="unknown" ;;
  esac
  case "$arch" in
    "i386" | "i686" | "x32" | "x86") arch="x32" ;;
    "amd64" | "x86_64") arch="x64" ;;
    "arm64" | "aarch64") arch="arm64" ;;
    *) arch="unknown" ;;
  esac
  if [ "$os" = "unknown" -o "$arch" = "unknown" ]; then
    echo "Unknown system."
    exit 1
  fi
  if [ "$os" = "linux" ]; then
    url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep "${os}_${arch}" | tee /dev/tty)
    filename=$(basename "$url")
    directory="tmp_dir"
    mkdir -p "$directory"
    curl -so "$directory/$filename" -L "$url"
    tar xf "$directory/$filename" -C "$directory"
    sudo mv "$directory/gitleaks" /usr/local/bin
    rm -rf "$directory"
    # sudo rm /usr/local/bin/gitleaks
  fi
  if [ "$os" = "windows" ]; then
    # url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep "${os}_${arch}" | tee /dev/tty)
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    powershell -Command "choco install gitleaks"
  fi
  if [ "$os" = "darwin" ]; then
    # url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep "${os}_${arch}" | tee /dev/tty)
    brew install gitleaks
  fi
}

# Update gitleaks
gitleaksUpdate() {
  gl_version=$(gitleaks version  | cut -d ' ' -f 3)
  url=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep browser_download_url | cut -d '"' -f 4 | grep "linux_x64")
  filename=$(basename "$url")
  version=$(echo "$filename" | cut -d '_' -f 2 | cut -d '.' -f 1-3)
  if [ "$gl_version" != "$version" ]; then
    echo ""
    echo "Gitleaks start update..."
    echo ""
    gitleaksInstall
    echo ""
    echo "Gitleaks finished update"
    echo ""
  fi
}

# Check if gitleaks installed
gitleaksInstalled() {
  if gitleaks version >/dev/null 2>&1; then
    gl_version=$(gitleaks version  | cut -d ' ' -f 3)
    gl_install=1
    echo "Gitleaks $gl_version"
  else
    gl_install=0
    echo "Gitleaks not installed"
  fi
  return $gl_install
}

# Main code
if [ "$(git config hooks.gitleaks)" = "true" ]; then
  gitleaksInstalled
  if [ $? -eq 0 ]; then
    echo ""
    echo "Gitleaks start installation..."
    echo ""
    gitleaksInstall
    echo ""
    echo "Gitleaks finished installation"
    echo ""
  fi
  # gitleaksUpdate
  gitleaks protect -v --staged --redact --
  if [ $? -ne 0 ]; then
    mistakes=1
  fi
else
  echo "Gitleaks disabled.To enable: git config hooks.gitleaks true"
  echo "=========================================================================================="
fi

##################################################################################################

# Check if there are errors
if [ $mistakes -eq 1 ]; then
: : integer expression expected
  echo "=========================================================================================="
  echo "Correct errors before proceeding..."
  exit 1
fi