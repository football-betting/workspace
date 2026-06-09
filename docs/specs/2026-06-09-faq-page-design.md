# FAQ-Seite — Design

**Datum:** 2026-06-09
**Ticket:** FE-094 (`faq-page`)
**Repo:** `frontend/`

## Hintergrund

Der Footer enthält bislang nur einen `/features`-Link. Es soll eine eigene
FAQ-Seite hinzukommen, die häufige Fragen rund um das Tipspiel in **Deutsch und
Englisch** beantwortet. Die Inhalte werden aus den bestätigten Spielregeln
abgeleitet (Punktesystem, Boni, Rangliste, Konto/Technik).

## Ziele

- Neue Seite unter `/faq`, im selben Layout wie `/features`.
- Inhalte vollständig in `messages/de.json` und `messages/en.json` (kein
  hartcodierter Text).
- Fragen als aufklappbares Accordion (native `<details>/<summary>`, kein
  Client-JS).
- Footer-Link zu `/faq` (nur Footer, keine Änderung an Haupt-Navigation).
- Vitest-Tests für Rendering + Übersetzungs-Parität.

## Nicht-Ziele

- Keine Suche/Filterung der FAQ.
- Kein Eintrag in TopAppBar/BottomNav.
- Keine CMS-/Markdown-Pipeline — Inhalte leben in den Message-JSONs.

## Architektur

### Route & Seite

Neue Server Component `app/(app)/faq/page.tsx`, Muster identisch zu
`app/(app)/features/page.tsx`:

```tsx
import { getTranslations } from "next-intl/server";
import { TopAppBar } from "@/components/dashboard/TopAppBar";
import { BottomNav } from "@/components/dashboard/BottomNav";

const FAQ_SECTIONS = [
  {
    key: "rules",
    items: [
      "howToTip",
      "deadline",
      "regularTimeOnly",
      "scoring",
      "winnerBonus",
      "secretWinner",
    ],
  },
  { key: "ranking", items: ["howRanking", "globalVsDepartment", "liveUpdate"] },
  {
    key: "account",
    items: [
      "whoCanRegister",
      "passwordReset",
      "reminders",
      "installApp",
      "languages",
    ],
  },
] as const;

export default async function FaqPage(): Promise<React.ReactElement> {
  const t = await getTranslations("FAQ");
  // TopAppBar active="dashboard" + <main> + section headings + <details> items + BottomNav
}
```

- `active="dashboard"` für TopAppBar/BottomNav (wie Features — kein eigener
  Nav-Slot).
- Gleicher `<main>`-Wrapper wie Features
  (`pt-4 md:pt-24 pb-24 md:pb-8 px-margin-mobile md:px-margin-desktop max-w-(--container-max-desktop) mx-auto`).

### Accordion (kein Client-JS)

Jede Frage ist ein `<details>`-Element, Frage im `<summary>`, Antwort im
Body. Styling über bestehende Theme-Tokens, analog zu den Feature-Karten
(`bg-surface-container rounded-lg border border-outline-variant`). Pfeil-/
Plus-Indikator über `group-open:`-Variante. Bleibt vollständig Server
Component.

### Übersetzungen

Neuer Top-Level-Key `FAQ` in **beiden** `messages/de.json` und
`messages/en.json`, mit identischem Key-Baum:

```jsonc
"FAQ": {
  "title": "...",
  "intro": "...",
  "sections": {
    "rules":   { "heading": "...", "items": { "howToTip": {"q":"...","a":"..."}, ... } },
    "ranking": { "heading": "...", "items": { ... } },
    "account": { "heading": "...", "items": { ... } }
  }
}
```

### Footer

Zweiter `<Link href="/faq">` neben dem bestehenden Features-Link in
`components/Footer.tsx`, neuer Key `Footer.faqHeading` in beiden Sprachen.

## FAQ-Inhalte (Quelle der Wahrheit)

### Block „Tippen & Regeln" / "Tipping & Rules"

| Key               | Frage (DE)                           | Antwort (DE, gekürzt)                                                                                                                          |
| ----------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `howToTip`        | Wie gebe ich einen Tipp ab?          | Auf dem Dashboard jedes anstehende Spiel auswählen, Tore für Heim und Gast eintragen und speichern. Ein Tipp pro Spiel.                        |
| `deadline`        | Bis wann kann ich tippen?            | Bis zum Anpfiff. Vorher lässt sich der Tipp beliebig oft ändern, danach ist er gesperrt.                                                       |
| `regularTimeOnly` | Welche Spielzeit zählt für den Tipp? | Gewertet wird die reguläre Spielzeit (90 Min. inkl. Nachspielzeit). In der K.-o.-Phase zählen Verlängerung und Elfmeterschießen **nicht** mit. |
| `scoring`         | Wie werden Punkte vergeben?          | 5 Punkte exaktes Ergebnis · 3 Punkte richtige Tordifferenz (kein Remis) · 2 Punkte richtige Tendenz bzw. korrektes Remis · 0 Punkte sonst.     |
| `winnerBonus`     | Was bringt der Turniersieger-Tipp?   | Wird dein offen gewählter Weltmeister tatsächlich Weltmeister, gibt es **+12 Bonuspunkte**.                                                    |
| `secretWinner`    | Was ist der „Secret Winner"?         | Ein zweiter, geheimer Sieger-Tipp (≠ offener Tipp). Wird dieses Team Weltmeister, gibt es **+6 Bonuspunkte**.                                  |

### Block „Rangliste & Abteilungen" / "Ranking & Departments"

| Key                  | Frage (DE)                             | Antwort (DE, gekürzt)                                                                                           |
| -------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `howRanking`         | Wie funktioniert die Rangliste?        | Punkte aus allen gewerteten Spielen plus Boni werden summiert; die Rangliste sortiert nach Gesamtpunkten.       |
| `globalVsDepartment` | Global vs. Abteilung?                  | Es gibt eine globale Rangliste und je eine pro Abteilung (Langenfeld, Mannheim, Mainz) — umschaltbar über Tabs. |
| `liveUpdate`         | Wann werden meine Punkte aktualisiert? | Während laufender Spiele live; Spielstände und Punkte aktualisieren sich automatisch.                           |

### Block „Konto & Technik" / "Account & Tech"

| Key              | Frage (DE)                           | Antwort (DE, gekürzt)                                                                                                                                                                                                           |
| ---------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `whoCanRegister` | Wer kann sich registrieren?          | Mitarbeitende mit einer valantic-E-Mail-Adresse.                                                                                                                                                                                |
| `passwordReset`  | Passwort vergessen?                  | Auf der Login-Seite „Passwort vergessen?" wählen, E-Mail eingeben — es kommt ein Link zum Zurücksetzen per Mail.                                                                                                                |
| `reminders`      | Werde ich an Spiele erinnert?        | Nur wenn du es aktivierst: in den Einstellungen mindestens einen Kanal einschalten — Push (im Browser/PWA) und/oder E-Mail. Danach kannst du die Vorlaufzeiten wählen; ohne aktiven Kanal werden keine Erinnerungen verschickt. |
| `installApp`     | Kann ich die App installieren?       | Ja, als PWA installierbar (Homescreen), inkl. Offline-Unterstützung und Push.                                                                                                                                                   |
| `languages`      | In welchen Sprachen gibt es die App? | Deutsch und Englisch. Am Desktop schaltest du die Sprache oben im Header um, auf dem Smartphone bzw. in der PWA in den Einstellungen.                                                                                           |

Die englischen Texte sind sinngemäße Übersetzungen derselben Inhalte.

## Tests

`frontend/`, Vitest:

Das Vitest-Setup läuft im `node`-Environment und sammelt nur
`tests/unit/**/*.test.ts` — ein echter RSC-Render-Test (async Server Component,
`server-only`) ist hier nicht möglich. Stattdessen wird die FAQ-Struktur in
`lib/faq.ts` ausgelagert und gegen die Übersetzungen geprüft:

1. **Content-Test** (`tests/unit/faq-content.test.ts`): `FAQ_SECTIONS` aus
   `lib/faq.ts` deckt 14 Fragen ab, keine doppelten Keys; für jeden Key
   existiert in `de.json` und `en.json` ein nicht-leeres `q`/`a` plus
   Section-`heading`. Die Seite rendert genau ein `<details>` pro Item,
   die Item-Anzahl ist damit der maßgebliche Invariant.
2. **Übersetzungs-Paritäts-Test** (bestehend, `tests/unit/i18n-messages.test.ts`):
   `de.json`/`en.json` haben identische Key-Struktur und keine leeren Strings —
   deckt die neuen `FAQ`-Keys automatisch ab.

Quality Gate `frontend/`: `prettier --write`, `tsc --noEmit`, `vitest run`.

## Betroffene Dateien

| Datei                                | Änderung                          |
| ------------------------------------ | --------------------------------- |
| `frontend/app/(app)/faq/page.tsx`    | **neu** — FAQ-Seite               |
| `frontend/messages/de.json`          | `FAQ`-Block + `Footer.faqHeading` |
| `frontend/messages/en.json`          | `FAQ`-Block + `Footer.faqHeading` |
| `frontend/components/Footer.tsx`     | `/faq`-Link                       |
| `frontend/app/(app)/faq/__tests__/…` | **neu** — Tests                   |
| `docs/FRONTEND_FUNKTIONS_SPEC.md`    | Spec-Sync (siehe unten)           |

## Spec-Sync (Doku an Ist-Stand angleichen)

Beim Recherchieren ist aufgefallen, dass `docs/FRONTEND_FUNKTIONS_SPEC.md` an
zwei Stellen nicht mehr den Code-Stand widerspiegelt. Im Rahmen dieses Tickets
mit korrigieren:

1. **Passwort-Reset ist kein Stub mehr.** §3 (`/password-forget`) und §6
   beschreiben den Reset als „auskommentiert / nicht implementiert". Tatsächlich
   existieren `app/(auth)/forgot-password`, `app/(auth)/reset-password` und die
   API-Routen `app/api/auth/forgot-password|reset-password` (E-Mail-basierter
   Token-Flow). Spec-Text auf „implementiert" aktualisieren.
2. **Neue Route `/faq`** in die Routen-Tabelle (§3) aufnehmen
   (Auth ✅, Layout wie Features, Aufgabe: statische FAQ).

## Offene Risiken

- Übersetzungs-Drift zwischen `de.json`/`en.json` → durch Paritäts-Test
  abgesichert.
- Punktwerte müssen mit `betting-api/src/service/mod.rs`
  (`WINNER_BONUS=12`, `SECRET_WINNER_BONUS=6`) konsistent bleiben — Werte sind
  hier dokumentiert, nicht neu berechnet.
