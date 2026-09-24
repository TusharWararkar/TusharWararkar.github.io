#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Puts this site on GitHub Pages under Tushar's account, then switches the
# GitHub CLI back to Janhavi so nothing else on this laptop is affected.
#
# Run it AFTER signing the CLI in as Tushar:
#     gh auth login
#
# Then:
#     bash setup-github.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

USER_NAME="TusharWararkar"
REPO="$USER_NAME.github.io"
KEY="$HOME/.ssh/id_ed25519_tushar"
JANHAVI="JanhaviWararkar10"

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '  \033[32mok\033[0m  %s\n' "$*"; }
fail() { printf '  \033[31mx\033[0m   %s\n' "$*"; exit 1; }

# ── 1. Confirm the CLI is acting as Tushar, not Janhavi ─────────────────────
say "1. Checking which GitHub account the CLI is using"
ACTIVE="$(gh api user --jq .login 2>/dev/null || true)"
[ -n "$ACTIVE" ] || fail "Not signed in. Run: gh auth login"
if [ "$ACTIVE" != "$USER_NAME" ]; then
  if gh auth switch --user "$USER_NAME" >/dev/null 2>&1; then
    ACTIVE="$(gh api user --jq .login)"
  else
    fail "Signed in as '$ACTIVE', not '$USER_NAME'. Run: gh auth login   (and pick Tushar's account)"
  fi
fi
ok "acting as $ACTIVE"

# ── 2. Register the deploy key on his account ───────────────────────────────
say "2. Registering the SSH key"
[ -f "$KEY.pub" ] || fail "Key missing at $KEY.pub"
FINGERPRINT="$(ssh-keygen -lf "$KEY.pub" | awk '{print $2}')"
if gh ssh-key list 2>/dev/null | grep -q "$(awk '{print $2}' "$KEY.pub" | cut -c1-40)"; then
  ok "already registered"
else
  gh ssh-key add "$KEY.pub" --title "Portfolio laptop" >/dev/null
  ok "added ($FINGERPRINT)"
fi

# ── 3. Create the repository if it isn't there ──────────────────────────────
say "3. Creating $USER_NAME/$REPO"
if gh repo view "$USER_NAME/$REPO" >/dev/null 2>&1; then
  ok "already exists"
else
  gh repo create "$USER_NAME/$REPO" --public \
    --description "Portfolio — sourcing & procurement engineer, chemicals and oil & gas" >/dev/null
  ok "created"
fi

# ── 4. Point the local repo at it and push ──────────────────────────────────
say "4. Pushing"
git remote remove origin 2>/dev/null || true
git remote add origin "git@github.com:$USER_NAME/$REPO.git"
git push -u origin main
ok "pushed as $(git log -1 --format='%an <%ae>')"

# ── 5. Turn on Pages, serving the repo root of main ─────────────────────────
say "5. Enabling GitHub Pages"
if gh api "repos/$USER_NAME/$REPO/pages" >/dev/null 2>&1; then
  ok "already enabled"
else
  gh api -X POST "repos/$USER_NAME/$REPO/pages" \
    -f 'source[branch]=main' -f 'source[path]=/' >/dev/null
  ok "enabled"
fi

# ── 6. Hand the CLI back to Janhavi ─────────────────────────────────────────
say "6. Restoring the CLI to Janhavi"
if gh auth switch --user "$JANHAVI" >/dev/null 2>&1; then
  ok "active account is now $(gh api user --jq .login)"
else
  printf '  note: could not switch back automatically. Run: gh auth switch --user %s\n' "$JANHAVI"
fi

say "Done — https://${USER_NAME,,}.github.io"
echo "  It can take a minute or two to go live on the first deploy."
echo "  From now on: edit src/page.html, run 'node build.js', commit, push."
