# WS-001 Result — Rust-Architektur-Empfehlungen

**Geschlossen**: 2026-05-28
**Commits**:
- workspace `7b5a7e8 WS-001: write Rust architecture recommendations`
- workspace `2624255 WS-001: ready for review`

## Was wurde gemacht

`docs/RUST_VERBESSERUNGEN.md` neu angelegt (335 Zeilen) — ein priorisierter
Empfehlungs-Backlog für `betting-api` und `macht-api`. Form pro Eintrag:
Befund mit `Datei:Zeile`, Risiko, Empfehlung, Aufwand (S/M/L).

Acht Prioritätsstufen, 19 Einzel-Findings:

| Stufe | Thema | Findings |
|---|---|---|
| P0 | Korrektheit | 2 (offene Owner-Fragen) |
| P1 | Härtung (`.unwrap()` raus) | 4 |
| P2 | Konfigurierbarkeit | 3 |
| P3 | Performance / DB | 2 |
| P4 | Code-Struktur | 3 |
| P5 | Observability | 1 |
| P6 | Schema / Migrationen | 2 |
| P7 | Testing | 2 |

Schluss-Sektion enthält die zwei offenen P0-Fragen an Owner:
1. Überschreibt `secret_winner == "ESP"` den `winner == "ESP"`-Bonus
   absichtlich? (`betting-api/src/service/mod.rs:55-66`)
2. Darf `Team.tla` nullable sein, wenn `macht-api` schreibt?
   (`betting-api/src/service/mod.rs:88-89`)

## Geänderte Dateien

- `docs/RUST_VERBESSERUNGEN.md` (neu)

## Quality-Gate

- Markdown reads as well-formed prose
- Prettier nicht installiert im Workspace → AC-Bedingung "Prettier
  check oder Hook auto-format" trivial erfüllt (Hook silently no-op)
- Manuelle Validierung: 19 Findings × Datei-Zeile-Ref, 19 × S/M/L,
  acht P-Sektionen in der spezifizierten Reihenfolge

## Reviewer-Feedback

Reviewer-Agent: **APPROVE**.

Zwei kleinere Genauigkeits-Hinweise (kein Blocker):
- P0.2 zitiert `Team`-Struct als `:34-41`, aktueller Stand ist `:28-35`
  (Off-by-Drift durch macht-api-Edits)
- P1.3 referenziert `panic!()` in `macht-api/src/main.rs:18-21`, der
  durch MA-002 bereits entfernt wurde. Das Doc selbst weist darauf hin
  ("Wird ohnehin durch MA-002 automatisch behoben")

Folge-Cleanup für die zwei Refs ist optional und kann gemeinsam mit
einem zukünftigen P1/P2-Ticket erfolgen.

## Folge-Aktionen

Owner entscheidet die zwei P0-Fragen → daraus konkrete BA-/MA-/XR-
Tickets ziehen. Davon hängt ab, ob P1.1/P1.4 als gebündeltes
Härtungs-Ticket oder pro Crate gezogen werden.
