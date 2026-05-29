# FE-030: Dauer der Rust-API-Aufrufe über Server-Timing-Header sichtbar machen

## Repo
frontend

## Type
feature

## Risk
low

## Priority
low

## Status
todo

## Owner
implementer

## Background
Beim Entwickeln und im produktiven Betrieb soll nachvollziehbar sein, wie lange die Aufrufe an die Rust-API dauern.  
Die Rust-API wird zentral über `frontend/lib/api.ts` (`fetchApi`) aufgerufen.

Die Messwerte sollen **nicht über `console.log`** ausgegeben werden, sondern im Browser über die DevTools sichtbar sein.  
Dafür soll ein `Server-Timing`-Header verwendet werden, damit die Dauer im Network-Tab nachvollziehbar ist.

## Scope

### In scope
- In `frontend/lib/api.ts` (`fetchApi`) die Dauer jedes Rust-API-Aufrufs messen.
- Messzeitraum: direkt vor `fetch` bis direkt nach Erhalt der Response bzw. bis zum Fehlerfall.
- Ausgabe über `Server-Timing`-Header.
- Die Messung darf in Development und Production aktiv sein.
- Erfolgreiche und fehlgeschlagene API-Aufrufe sollen messbar sein.
- Kein Logging über `console.log`.
- Keine persistente Speicherung der Messwerte.
- Keine Änderung am Verhalten von `fetchApi`.

### Out of scope
- Konsolen-Logging.
- On-Screen Dev-Overlay.
- Vollständiges Monitoring-System.
- Datenbank-Logging.
- Messung innerhalb der Rust-Services selbst.
- Tracing über mehrere Services.
- Performance-Dashboard.

## References
- `frontend/lib/api.ts` — `fetchApi`, zentraler Pfad zur Rust-API
- `frontend/app/(app)/page.tsx`
- `frontend/app/(app)/ranking/page.tsx`
- `frontend/app/(app)/match/[id]/page.tsx`
- `frontend/app/(app)/user/[id]/page.tsx`

## Implementation Notes

### Gewählte Variante
Die Dauer soll über den HTTP-Header `Server-Timing` sichtbar gemacht werden.

Beispiel:

```http
Server-Timing: rust-api;dur=123;desc="GET /ranking"
```

Bei mehreren API-Aufrufen innerhalb eines Page-Requests können mehrere Werte kombiniert werden:

```http
Server-Timing: rust-api-1;dur=94;desc="GET /matches", rust-api-2;dur=118;desc="GET /ranking"
```

### Wichtig
Falls `fetchApi` direkt in Server Components oder serverseitigen Funktionen verwendet wird, muss die Messung gesammelt und am Ende als Header auf die Page-/Route-Response geschrieben werden.

Falls das technisch im aktuellen Next.js/Astro-Setup nicht sauber global möglich ist, ist eine pragmatische Zwischenlösung erlaubt:

- Server-Timing zunächst nur für Route Handler / API-Proxies umsetzen.
- Direkte Server-Component-Aufrufe später über einen zentralen Wrapper oder Request-Context erweitern.

### Anforderungen an die Header-Ausgabe
- Header-Name: `Server-Timing`
- Dauer in Millisekunden über `dur`
- Beschreibung über `desc`
- Methode und Pfad dürfen enthalten sein.
- Keine Tokens, Cookies, Authorization-Header oder Request-Bodies im Header ausgeben.
- Query-Parameter nur verwenden, wenn sie keine sensiblen Daten enthalten. Im Zweifel entfernen oder maskieren.

### Beispiel
```http
Server-Timing: rust-api;dur=87;desc="POST /predictions"
```

Im Browser sichtbar unter:

```text
DevTools → Network → Request auswählen → Headers → Response Headers
DevTools → Network → Request auswählen → Timing
```

## Acceptance Criteria
- [ ] Für Rust-API-Aufrufe über `fetchApi` wird die Dauer gemessen.
- [ ] Die Dauer wird über `Server-Timing` sichtbar gemacht.
- [ ] Es gibt kein `console.log` für die Timing-Ausgabe.
- [ ] Die Lösung ist in Development aktiv.
- [ ] Die Lösung ist auch in Production aktiv.
- [ ] Erfolgreiche Requests enthalten Dauer, Methode und Endpoint.
- [ ] Fehlgeschlagene Requests enthalten ebenfalls die Dauer bis zum Fehler, soweit technisch möglich.
- [ ] Es werden keine sensiblen Daten in Header geschrieben.
- [ ] Request-Bodies werden nicht in Header geschrieben.
- [ ] Authorization-Header, Cookies und Tokens werden nicht in Header geschrieben.
- [ ] Verhalten von `fetchApi` bleibt unverändert.
- [ ] Rückgabewerte von `fetchApi` bleiben unverändert.
- [ ] Fehler werden weiterhin wie bisher weitergereicht.
- [ ] Quality Gate passes in `frontend`:
    - `pnpm exec tsc --noEmit`
    - `pnpm exec vitest run`

## Verification

### Manual
1. `pnpm dev` starten.
2. Browser DevTools öffnen.
3. Dashboard laden.
4. Im Network-Tab den Page-Request oder relevanten Route/API-Request auswählen.
5. Prüfen, ob ein `Server-Timing`-Header vorhanden ist.
6. Ranking oder Match-Detail öffnen.
7. Prüfen, ob weitere Rust-API-Aufrufe als Timing sichtbar werden.
8. Production Build starten.
9. Prüfen, ob `Server-Timing` auch dort sichtbar ist.

### Expected Header
```http
Server-Timing: rust-api;dur=123;desc="GET /ranking"
```

oder bei mehreren Rust-API-Aufrufen:

```http
Server-Timing: rust-api-1;dur=94;desc="GET /matches", rust-api-2;dur=118;desc="GET /ranking"
```

## Notes
Die reine Messung mit `performance.now()` ist sehr leichtgewichtig.  
Der Vorteil von `Server-Timing` gegenüber `console.log` ist, dass die Information dort sichtbar ist, wo Performance analysiert wird: im Browser-Network-Tab.

Falls die technische Architektur keine globale Header-Erweiterung für alle `fetchApi`-Aufrufe erlaubt, soll der Implementer das sauber dokumentieren und die nächstbeste zentrale Stelle verwenden.
