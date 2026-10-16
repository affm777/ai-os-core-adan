# Verbotsliste gegen AI-Slop

Diese Liste gilt für jede Fassung in jedem Kanal und jeder Sprache. Sie ist ein Startpunkt. Eigene Ergänzungen gehören in deinen Stil-Korpus `content/voice.md` unter „Eigene Verbote“, dann bleiben sie bei einem Update des Skills erhalten.

## Regeln

1. Keine Floskeln. Sätze, die in jeden beliebigen Text passen würden, fliegen raus („In der heutigen schnelllebigen Welt“, „Es ist kein Geheimnis, dass“).
2. Keine Aufzählungen mit Emojis als Aufzählungszeichen.
3. Keine drei Adjektive in Reihe („inspirierend, bewegend und einzigartig“).
4. Keine rhetorische Frage als Einstieg („Kennst du das?“, „Was macht eigentlich gutes Mentoring aus?“).
5. Kein „Lass uns gemeinsam“ oder „Lasst uns gemeinsam“ und keine englische Entsprechung („Let's build together“).
6. Keine Gedankenstriche, weder „–“ noch „—“ noch ein Bindestrich mit Leerzeichen davor und dahinter. Stattdessen Komma, Punkt, Doppelpunkt oder Klammern.
7. Kein Hashtag-Teppich. Höchstzahl je Kanal steht in der Kanalkarte, im Fließtext stehen keine Hashtags.
8. Keine Großschreibung zur Betonung („Das ist WICHTIG“). Abkürzungen wie ADAN oder EU sind erlaubt.
9. Kein Markdown-Schmuck in Kanaltexten (Sternchen, Rauten als Überschrift, Unterstriche zur Betonung).
10. Keine Wertung ohne Beleg aus dem Rohtext (Superlative wie „großartig“, „unglaublich“, „einzigartig“).
11. Keine Mehrfach-Satzzeichen („!!!“, „?!“).

## Prüfmuster

Die Zeilen im folgenden Block prüft `scripts/pruefen.sh` ohne Rücksicht auf Groß- und Kleinschreibung (erweiterte reguläre Ausdrücke). Eine Zeile ist ein Muster. Gedankenstriche, Emoji-Aufzählungen, Hashtags, Großschreibung, Markdown und Fragezeilen prüft das Script fest eingebaut.

```muster
in der heutigen
schnelllebig
heutzutage
es ist kein geheimnis
in einer welt, in der
lass(t)? uns gemeinsam
gemeinsam (die zukunft|etwas) (gestalten|bewegen)
spannende reise
auf (eine|die|diese) reise
das nächste level
game.?changer
mehrwert
synergie
ganzheitlich
tauch(en wir|t|e|en sie) ein
nicht mehr wegzudenken
mehr als nur
unglaublich
einzigartig
großartig
revolution(är|ieren)
bahnbrechend
in today'?s
fast.?paced
ever.?(changing|evolving)
let'?s (dive|build|create|shape|grow|make|work)( [a-z]+)? together
let'?s dive
dive (in|into|deep)
deep dive
delve
unlock
unleash
elevate
journey
game.?changing
testament to
tapestry
seamless
cutting.?edge
groundbreaking
incredible
amazing
!!+
\?!
