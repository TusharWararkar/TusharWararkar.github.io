# Portfolio — Tushar Wararkar

Buyer · Sourcing & Procurement Engineer — chemicals, oil & gas.
A single-page site. No frameworks, no dependencies, no `npm install`.

## Files

| File | What it is |
| --- | --- |
| `src/page.html` | **The source of truth.** All markup, CSS and JS. Edit this file. |
| `src/assets/portrait.jpg` | His photo. Replace this file and rebuild to change it. |
| `build.js` | Builds both outputs from `src/page.html`. |
| `index.html` | **Generated — don't edit.** The deployable site. |
| `assets/portrait.jpg` | Generated copy, sits next to `index.html`. |
| `dist/artifact.html` | **Generated.** Published as the shareable Claude Artifact (portrait inlined). |
| `Tushar_Wararkar_Resume.pdf` | Linked from the "Résumé" buttons. |

## Editing

```bash
node build.js
```

Preview locally:

```bash
python -m http.server 4322
```

Then open <http://localhost:4322>. Add `?still=1` to freeze all animation — useful
for screenshots or checking layout.

## Adding his reading list

The **On the shelf** section is hidden until it has books in it, so the site never
shows an empty shelf. To switch it on, find `var BOOKS = [` near the bottom of
`src/page.html` and fill it in:

```js
var BOOKS = [
  { title: "Book title", author: "Author name", note: "One line on why it stuck." },
];
```

`note` is optional. The section appears automatically, and Contact renumbers itself
from 06 to 07. Then run `node build.js`.

## Design notes

Chemistry as the visual language, procurement as the substance — so it looks like a
chemical engineer made it, but reads like a buyer's portfolio.

- **The atom** — his photo is the nucleus, with three tilted orbital shells and three
  electrons that travel the ellipses via CSS `offset-path`. Each electron runs at a
  different period (8s / 11s / 14s) so they never fall into lockstep.
- **The buying cycle** — his actual job drawn as a reaction pathway: Requirement →
  Enquiry → Evaluation → Negotiation → Award → Expediting → At site. A highlight
  walks the chain, and pauses when the section scrolls off screen or the tab hides.
- **Periodic table of competencies** — the ten core competencies from his résumé as
  element tiles, colour-coded into four groups (sourcing, commercial, execution,
  insight). Symbols are real abbreviations of the competency, not decoration.

Tokens:

- **Colour** — lab bench light by default: off-white ground (`#EEF1ED`), viridian
  primary (`#0E6A4E`, 5.77:1), copper for energy and outcomes (`#A8450F`, 5.24:1),
  cupric blue for analysis (`#1F5F93`, 5.91:1). Dark mode is the same bench at night
  and brightens all three (10.6:1, 8.4:1, 8.9:1).
- **Type** — Bricolage Grotesque, IBM Plex Sans, IBM Plex Mono. Deliberately the same
  stack as Janhavi's portfolio so the two read as a matched pair.
- **Motion** — everything respects `prefers-reduced-motion`.

---

# Pushing to GitHub as Tushar (without touching Janhavi's account)

This laptop is signed in to GitHub as **Janhavi**, globally. Nothing below changes
that. His identity is scoped to this one folder.

**What's already configured in this repo:**

| Setting | Value | Scope |
| --- | --- | --- |
| `user.name` | Tushar Wararkar | this repo only |
| `user.email` | twararkar8380@gmail.com | this repo only |
| `core.sshCommand` | uses `id_ed25519_tushar` | this repo only |

Her global `user.name`, `user.email` and the Windows credential manager are
untouched. Commits from this folder are authored by Tushar; commits from anywhere
else on the laptop are still authored by Janhavi.

A dedicated SSH key was generated for him at `C:\Users\janha\.ssh\id_ed25519_tushar`,
separate from her `id_ed25519`. Because the repo pushes over SSH with
`IdentitiesOnly=yes`, it never consults her key and never goes near Git Credential
Manager — which is what would otherwise silently push as her.

## Steps — he does these himself

**1. Add his public key to his GitHub account.**
Sign in as **TusharWararkar**, go to <https://github.com/settings/keys> → *New SSH
key*, title it something like "Janhavi's laptop", and paste:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7eD9hlZQpnaTFwnw4oIyQ/lsgkH9iOI2kd5IeWtQ+h twararkar8380@gmail.com
```

**2. Create an empty repo.** At <https://github.com/new>, signed in as him, named
`TusharWararkar.github.io`. No README, no .gitignore — leave it completely empty.
That exact name is what gives him `https://tusharwararkar.github.io` as the URL.

**3. Connect and push.** From this folder:

```bash
git remote add origin git@github.com:TusharWararkar/TusharWararkar.github.io.git
```

```bash
git add -A && git commit -m "Portfolio site"
```

```bash
git push -u origin main
```

**4. Turn on Pages.** Repo → *Settings* → *Pages* → Source: *Deploy from a branch* →
`main` / `root`. Live at <https://tusharwararkar.github.io> in about a minute.

## Verify it went out as him, not her

```bash
git log -1 --format='%an <%ae>'
```

Should print `Tushar Wararkar <twararkar8380@gmail.com>`. And to confirm the key
resolves to his account:

```bash
ssh -i ~/.ssh/id_ed25519_tushar -o IdentitiesOnly=yes -T git@github.com
```

GitHub replies `Hi TusharWararkar!` — if it says `Hi Janhavi...`, the wrong key is
being offered, so re-check `git config core.sshCommand` in this folder.

## Security note

The private key at `C:\Users\janha\.ssh\id_ed25519_tushar` has **no passphrase**, so
anyone with access to this laptop can push to his GitHub. Two ways to tighten that:

Add a passphrase (he'll be prompted on each push):

```bash
ssh-keygen -p -f ~/.ssh/id_ed25519_tushar
```

Or delete the key when the site is done, and revoke it at
<https://github.com/settings/keys>:

```bash
rm ~/.ssh/id_ed25519_tushar ~/.ssh/id_ed25519_tushar.pub
```

## Things to update

- **His reading list** — see above; the section is waiting on it.
- `Rev. 1.0` in the rail and colophon — bump on substantial changes.
- The résumé PDF link only resolves once deployed; on the Claude Artifact preview
  it 404s, because the artifact can't reach sibling files.
