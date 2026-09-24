#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Puts this site on GitHub Pages under Tushar's account, then hands the GitHub
# CLI back to Janhavi so nothing else on this laptop is affected.
#
# If the CLI isn't signed in as Tushar yet:   gh auth login
# Then:                                       bash setup-github.sh
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
    fail "Signed in as '$ACTIVE'. Run: gh auth login and pick Tushar's account"
  fi
fi
ok "acting as $ACTIVE"

# ── 2. Confirm the SSH key reaches GitHub as him ────────────────────────────
# Asking the key who it is beats listing keys, which needs an extra CLI scope.
say "2. Checking the SSH key"
[ -f "$KEY.pub" ] || fail "Key missing at $KEY.pub"
SSH_REPLY="$(ssh -i "$KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new \
             -o BatchMode=yes -o ConnectTimeout=10 -T git@github.com 2>&1 || true)"
WHO="$(printf '%s' "$SSH_REPLY" | sed -n 's/^Hi \([A-Za-z0-9-]*\)!.*/\1/p')"

if [ "$WHO" = "$USER_NAME" ]; then
  ok "key authenticates as $WHO"
elif [ -n "$WHO" ]; then
  fail "key authenticates as '$WHO', not '$USER_NAME' — the wrong key is being offered"
else
  if gh ssh-key add "$KEY.pub" --title "Portfolio laptop" >/dev/null 2>&1; then
    ok "key registered"
  else
    echo "  The key isn't on his account, and the CLI lacks permission to add it."
    echo "  Either run:  gh auth refresh -h github.com -s admin:public_key"
    echo "  and re-run this script, or paste the line below at"
    echo "  https://github.com/settings/keys"
    echo
    cat "$KEY.pub"
    exit 1
  fi
fi

# ── 3. Create the repository if it isn't there ──────────────────────────────
say "3. Repository $USER_NAME/$REPO"
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
say "5. GitHub Pages"
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
  echo "  note: couldn't switch back. Run: gh auth switch --user $JANHAVI"
fi

say "Done — https://tusharwararkar.github.io"
echo "  First deploy takes a minute or two."
echo "  From now on: edit src/page.html, run 'node build.js', commit, push."
