# Aktien-Risiko-Kennzahlen

Ein kleines Tool in **R**, das aus historischen Kursdaten automatisiert die
wichtigsten Marktrisiko-Kennzahlen einer Aktie berechnet und ausgibt.

Das Projekt entstand aus persönlichem Interesse an quantitativem
Risikomanagement und der Automatisierung von Risikoreportings.

## Was das Tool macht

Es lädt die Kurshistorie einer Aktie von Yahoo Finance und berechnet drei
klassische Risiko-Kennzahlen:

- **Volatilität (annualisiert)** – die Schwankungsbreite der Renditen,
  hochgerechnet auf ein Jahr. Standardmaß für das Risiko einer Position.
- **Value-at-Risk (95%, historisch)** – der Verlust, der an 95 % der Tage
  nicht überschritten wird. Berechnet über das empirische Quantil der
  Renditeverteilung, ohne Verteilungsannahme.
- **Maximum Drawdown** – der größte Wertverlust von einem bisherigen
  Höchststand bis zum darauffolgenden Tief.

Zusätzlich wird die Renditeverteilung als Histogramm mit eingezeichneter
VaR-Grenze visualisiert.

## Verwendete Verfahren

- empirische Quantil-Schätzung (historischer Value-at-Risk)
- Streuungs- und Drawdown-Statistik aus Zeitreihen von Tagesrenditen
- automatisierte Datenbeschaffung und Reporting in R

## Verwendung

Voraussetzung ist eine R-Installation. Das benötigte Paket wird beim ersten
Start automatisch installiert.

```r
source("Risiko_Kennzahlen.R")
```

Die Aktie und die Parameter lassen sich oben im Skript anpassen:

```r
ticker = "BMW.DE"   # zu analysierende Aktie
conf   = 0.95       # Konfidenzniveau für den VaR
jahre  = 2          # Länge der Kurshistorie
```

## Beispiel-Ausgabe

```
=============================================
  RISIKO-REPORT:   BMW.DE
=============================================
  Volatilität (p.a.):       28.4 %
  Value-at-Risk (95%):       2.9 %   pro Tag
  Maximum Drawdown:         41.2 %
=============================================
```

*(Die Werte sind beispielhaft und hängen vom Abrufzeitpunkt ab.)*

## Technik

- **Sprache:** R
- **Paket:** quantmod (Kursdatenabruf)
- **Datenquelle:** Yahoo Finance

## Mögliche Erweiterungen

- Vergleich mehrerer Aktien nebeneinander in einer Tabelle
- Export der Ergebnisse als Excel-Report
- parametrischer und Monte-Carlo-VaR als zusätzliche Methoden
- Backtesting zur Validierung der VaR-Schätzung
