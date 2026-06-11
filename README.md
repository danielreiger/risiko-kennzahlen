# Portfolio-Risiko-Kennzahlen (R)

Ein schlankes R-Tool zur Quantifizierung von Marktrisiken eines Aktienportfolios.
Es lädt Kursdaten von Yahoo Finance, berechnet die zentralen Risikokennzahlen und
zeigt über die Korrelationsmatrix und den Diversifikationseffekt, wie sich das
Risiko durch Streuung über mehrere Titel verändert.

Ein einzelner Ticker liefert weiterhin die klassische Einzelaktien-Analyse – das
Tool funktioniert für ein wie für mehrere Wertpapiere.

## Kennzahlen

- **Volatilität (p.a.)** – annualisierte Standardabweichung der Tagesrenditen
- **Value-at-Risk (historisch)** – empirisches (1 − Konfidenz)-Quantil der Tagesrenditen
- **Maximum Drawdown** – größter Wertverlust vom Hoch bis zum darauffolgenden Tief
- **Korrelationsmatrix** – Gleichlauf der einzelnen Titel
- **Diversifikationseffekt** – Anteil des Risikos, der durch Streuung wegfällt

## Voraussetzungen

- R (ab Version 4.x)
- Paket [`quantmod`](https://cran.r-project.org/package=quantmod) (wird beim ersten Lauf
  automatisch installiert)

## Nutzung

1. Repository klonen oder `portfolio_risiko_kennzahlen.R` herunterladen.
2. In **STEP 1** die Einstellungen anpassen:

```r
ticker   = c("BMW.DE", "SAP.DE", "ALV.DE", "SIE.DE")  # gewünschte Titel
gewichte = c(0.25,     0.25,     0.25,     0.25)       # Portfoliogewichte
conf     = 0.95     # Konfidenzniveau für den VaR
jahre    = 2        # Länge der Kurshistorie in Jahren
```

3. Das Skript ausführen (z. B. `source("portfolio_risiko_kennzahlen.R")` oder in RStudio).

Die Gewichte werden automatisch auf eine Summe von 1 normiert. Für eine einzelne
Aktie genügt `ticker = "BMW.DE"` und `gewichte = 1`.

## Beispiel-Output

```
==================================================
  PORTFOLIO-RISIKO-REPORT
==================================================
  Titel:
    BMW.DE    Gewicht 25.0 %
    SAP.DE    Gewicht 25.0 %
    ALV.DE    Gewicht 25.0 %
    SIE.DE    Gewicht 25.0 %
--------------------------------------------------
  Volatilität (p.a.):             21.4 %
  Value-at-Risk (95%):             2.1 %  pro Tag
  Maximum Drawdown:               28.7 %
  Diversifikationseffekt:         14.3 %
==================================================
```

(Werte sind illustrativ und hängen von Titelauswahl und Zeitraum ab.)

Zusätzlich gibt das Skript die Korrelationsmatrix der Tagesrenditen aus und
zeichnet ein Histogramm der Portfolio-Tagesrenditen mit eingezeichneter VaR-Schwelle.

## Methodik & Annahmen

- **Renditen:** einfache Tagesrenditen auf Basis dividenden- und splitbereinigter
  Schlusskurse (`Ad()`).
- **Portfoliorendite:** gewichtete Summe der Einzelrenditen; die Gewichte gelten
  über den gesamten Zeitraum (kein Rebalancing-Modell).
- **VaR:** rein historisch geschätzt – er unterstellt, dass die vergangene
  Renditeverteilung die Zukunft beschreibt, und macht keine Verteilungsannahme.
- **Annualisierung:** Volatilität wird mit √252 hochskaliert (≈ Börsentage pro Jahr).
- **Datengrundlage:** nur Handelstage, an denen für *alle* Titel Kurse vorliegen
  (gemeinsame Schnittmenge nach `na.omit`).

## Mögliche Erweiterungen

- Parametrische (Varianz-Kovarianz-) und Monte-Carlo-basierte VaR-Schätzung
- Backtesting der VaR-Güte (z. B. Ampel-/Kupiec-Test)
- Marginaler und Komponenten-VaR je Titel
- Rollierende Kennzahlen über die Zeit

## Autor

Daniel Reiger
