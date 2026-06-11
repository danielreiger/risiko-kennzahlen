# ============================================================
#  PORTFOLIO-RISIKO-KENNZAHLEN  |  R
#  Volatilitaet + Value-at-Risk + Maximum Drawdown + Korrelation
#
#  Daniel Reiger
# ============================================================

# ---- Paket installieren (nur beim ersten Mal noetig) ----
if (!requireNamespace("quantmod", quietly = TRUE)) install.packages("quantmod")
library(quantmod)   # laedt Kursdaten von Yahoo Finance

# ============================================================
#  STEP 1: EINSTELLUNGEN  (hier kannst du alles aendern)
# ============================================================
ticker   = c("BMW.DE", "SAP.DE", "ALV.DE", "SIE.DE")  # welche Aktien?
gewichte = c(0.25,     0.25,     0.25,     0.25)       # Portfoliogewichte
conf     = 0.95     # Konfidenzniveau fuer den VaR (95%)
jahre    = 2        # wie viele Jahre Historie?

# Tipp: Fuer eine EINZELNE Aktie einfach nur einen Ticker eintragen,
#       z.B. ticker = "BMW.DE" und gewichte = 1.

# Gewichte auf Summe 1 normieren (falls sie nicht exakt aufgehen)
gewichte = gewichte / sum(gewichte)

# Sicherheitscheck: gleich viele Gewichte wie Ticker?
if (length(ticker) != length(gewichte))
  stop("Anzahl Ticker und Anzahl Gewichte stimmen nicht ueberein.")

# ============================================================
#  STEP 2: KURSDATEN LADEN (alle Titel) UND ZUSAMMENFUEHREN
# ============================================================
message("Lade Kursdaten fuer ", length(ticker), " Titel ...")

preis_liste = list()
for (t in ticker) {
  kurse = getSymbols(t, src = "yahoo",
                     from = Sys.Date() - 365 * jahre,
                     auto.assign = FALSE)
  preis_liste[[t]] = Ad(kurse)   # Ad() = um Dividenden/Splits bereinigt
}

# Alle Kursreihen zu EINER Tabelle zusammenfuegen und auf
# gemeinsame Handelstage reduzieren (Zeilen mit Luecken entfernen)
preise_xts = na.omit(do.call(merge, preis_liste))
colnames(preise_xts) = ticker
preise_mat = as.matrix(preise_xts)

message("Gemeinsame Handelstage: ", nrow(preise_mat))

# ============================================================
#  STEP 3: TAGESRENDITEN BERECHNEN (je Titel)
# ============================================================
# Rendite = prozentuale Veraenderung von einem Tag zum naechsten.
# diff() bildet die Differenz spaltenweise, head(..., -1) liefert
# den jeweiligen Vortagespreis als Nenner.
renditen_mat = diff(preise_mat) / head(preise_mat, -1)

# ============================================================
#  STEP 4: PORTFOLIO-RENDITE (gewichtet)
# ============================================================
# Taegliche Portfoliorendite = gewichtete Summe der Einzelrenditen
port_rend = as.numeric(renditen_mat %*% gewichte)

# Portfolio-Preisindex (Start = 100) als Basis fuer den Drawdown
port_index = 100 * cumprod(1 + port_rend)

# ============================================================
#  STEP 5: DIE DREI RISIKO-KENNZAHLEN (Portfolio)
# ============================================================
# (1) VOLATILITAET (annualisiert)
#     Standardabweichung der Tagesrenditen, hochgerechnet aufs Jahr.
#     252 = ungefaehr die Anzahl Boersentage pro Jahr.
vola_taeglich = sd(port_rend)
vola_jahr     = vola_taeglich * sqrt(252)

# (2) VALUE-AT-RISK (historisch)
#     Das schlechteste (1 - conf)-Quantil der echten Renditen.
#     Bei conf = 0.95 also das 5%-Quantil -> als Verlust positiv.
VaR = -quantile(port_rend, 1 - conf)

# (3) MAXIMUM DRAWDOWN
#     Groesster Verlust von einem bisherigen Hoechststand bis zum Tief.
hoechststand = cummax(port_index)               # laufendes Allzeithoch
drawdowns    = (port_index - hoechststand) / hoechststand
max_drawdown = -min(drawdowns)                  # als positive Zahl

# ============================================================
#  STEP 6: KORRELATION & DIVERSIFIKATIONSEFFEKT
# ============================================================
# Korrelationsmatrix der Einzelrenditen: zeigt, wie stark sich
# die Titel gemeinsam bewegen (1 = Gleichlauf, 0 = unabhaengig).
korr = cor(renditen_mat)

# Annualisierte Vola jedes Einzeltitels
vola_einzel = apply(renditen_mat, 2, sd) * sqrt(252)

# Risiko OHNE Diversifikation = gewichtete Summe der Einzelvolas
# (so waere die Vola, wenn sich alle Titel perfekt gleich bewegten)
vola_ohne_diversifikation = sum(gewichte * vola_einzel)

# Diversifikationseffekt = wie viel Risiko durch die Streuung wegfaellt
diversifikation = 1 - vola_jahr / vola_ohne_diversifikation

# ============================================================
#  STEP 7: ERGEBNIS AUSGEBEN
# ============================================================
cat("\n", strrep("=", 50), "\n", sep = "")
cat("  PORTFOLIO-RISIKO-REPORT\n")
cat(strrep("=", 50), "\n", sep = "")
cat("  Titel:\n")
for (i in seq_along(ticker))
  cat(sprintf("    %-8s  Gewicht %4.1f %%\n", ticker[i], gewichte[i] * 100))
cat(strrep("-", 50), "\n", sep = "")
cat(sprintf("  Volatilitaet (p.a.):          %6.1f %%\n", vola_jahr * 100))
cat(sprintf("  Value-at-Risk (%g%%):          %6.1f %%  pro Tag\n",
            conf * 100, VaR * 100))
cat(sprintf("  Maximum Drawdown:             %6.1f %%\n", max_drawdown * 100))
cat(sprintf("  Diversifikationseffekt:       %6.1f %%\n", diversifikation * 100))
cat(strrep("=", 50), "\n", sep = "")
cat("  Lesart VaR: An 95% der Tage liegt der Tagesverlust\n")
cat("              des Portfolios unter dem VaR-Wert.\n")
cat("  Lesart Diversifikation: So viel Risiko faellt durch\n")
cat("              das Streuen ueber mehrere Titel weg.\n\n")

cat("  Korrelationsmatrix der Tagesrenditen:\n")
print(round(korr, 2))
cat("\n")

# ============================================================
#  STEP 8: GRAFIK - Renditeverteilung mit VaR-Linie
# ============================================================
hist(port_rend, breaks = 50, col = "#D6E4F0", border = "white",
     main = "Tagesrenditen: Portfolio",
     xlab = "Tagesrendite", ylab = "Haeufigkeit")
abline(v = -VaR, col = "#FF6600", lwd = 2, lty = 2)
legend("topleft", bty = "n",
       legend = paste0("VaR (", conf * 100, "%)"),
       col = "#FF6600", lwd = 2, lty = 2)
