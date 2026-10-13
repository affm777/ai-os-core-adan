# Code-Quality-Security

OWASP Top 10, Quality Gates, Code-Review-Trigger, Input Validation. Ergänzt `rules/security-basics.md`.

## Credentials

| Niemals | Stattdessen |
|---|---|
| API-Keys in Code oder Workflows | Environment Variables, Credentials Manager |
| Secrets in Git committen | `.gitignore` plus Secret Manager |
| Hardcoded URLs mit Auth | Credential-Referenzen |
| Tokens in Logs ausgeben | Maskierte Ausgabe |

Vor jedem Commit Secret-Scan. Erzwungen durch den PreToolUse-Hook `~/.claude/hooks/git-secret-scan.sh` (blockt `git commit` bei Verdacht im gestagten Diff). Manueller Fallback:
```bash
git diff --cached | grep -iE "(api.?key|secret|password|token|bearer)"
```

## Input Validation
- Webhooks: Signatur-Validierung (HMAC), wo möglich.
- User-Input: immer sanitizen, nie direkt in Queries oder Code.
- URLs: nur HTTPS, Domain-Whitelist für Redirects.
- File-Uploads: Typ-Check, Größenlimits, keine Ausführung.

## OWASP Top 10 (bei Code-Erstellung mental durchgehen)

| # | Risiko | Maßnahme |
|---|---|---|
| 1 | Injection | Parameterized Queries, keine String-Konkatenation |
| 2 | Broken Auth | Session-Management, Token-Expiry |
| 3 | Sensitive Data | Verschlüsselung at rest und in transit |
| 4 | XXE | XML-Parser sicher konfigurieren |
| 5 | Broken Access Control | Autorisierung auf dem Server, nicht im Client |
| 6 | Security Misconfig | Keine Default-Credentials, Header setzen |
| 7 | XSS | Output-Encoding, CSP-Header |
| 8 | Insecure Deserialization | JSON bevorzugen, Typen validieren |
| 9 | Vulnerable Components | Dependencies aktuell halten |
| 10 | Logging | Audit-Trail, aber keine Secrets loggen |

## Quality Gates (vor Abschluss einer Aufgabe)
- Happy Path funktioniert?
- Edge Cases abgedeckt (leere Inputs, Nulls, Timeouts)?
- Error Handling vorhanden (kein Silent Fail)?
- Testbar (manuell oder automatisiert)?
- Security-Review gemacht?

## Code-Review-Trigger
Automatisch `feature-dev:code-reviewer` aufrufen bei neuem Endpoint oder Webhook, Änderungen an Authentifizierung oder Autorisierung, Datenbank-Schema-Änderungen, externer API-Integration, File- oder Upload-Handling. (Der Trigger steht zusätzlich einzeilig in `rules/security-basics.md`.)
