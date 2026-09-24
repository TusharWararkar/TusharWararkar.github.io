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

# Pushing to GitHub as Tushar

The site is live at <https://tusharwararkar.github.io> and deploys straight from
`main`. Every push rebuilds it; there is no pipeline to maintain.

This laptop is signed in to GitHub as **Janhavi** globally. Nothing here changes
that. Settings scoped to this folder only:

| Setting | Value |
| --- | --- |
| `user.name` / `user.email` | Tushar Wararkar / twararkar8380@gmail.com |
| `credential.https://github.com.helper` | `!gh auth git-credential` |
| remote | `https://github.com/TusharWararkar/TusharWararkar.github.io.git` |

Git borrows the GitHub CLI's login rather than using a stored key or password,
so there is no private key sitting on the laptop to leak. Commits from this
folder are authored by Tushar; commits anywhere else are still Janhavi's.

## To push

The CLI must be on his account first:

```bash
gh auth switch --user TusharWararkar
```

Then the normal loop:

```bash
node build.js && git add -A && git commit -m "your message" && git push
```

And hand the CLI back when done:

```bash
gh auth switch --user JanhaviWararkar10
```

`setup-github.sh` does all of the above in one run, including the Pages settings,
and is safe to re-run.

## If the site stops updating

Check that Pages is still building from the branch, not from a workflow:

```bash
gh api repos/TusharWararkar/TusharWararkar.github.io/pages --jq .build_type
```

It must say `legacy`. If it says `workflow`, Pages is waiting for a GitHub
Actions run that this repo does not have, and the site will silently freeze.
Fix it with:

```bash
gh api -X PUT repos/TusharWararkar/TusharWararkar.github.io/pages -f build_type=legacy -f 'source[branch]=main' -f 'source[path]=/'
```

## Things to update

- The reading list is the `BOOKS` array near the bottom of `src/page.html`.
  Add `{ title, author, short, sub, tag, colour }` entries and rebuild.
- `Rev. 1.0` in the rail and colophon, on substantial changes.
