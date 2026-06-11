# ============================================================
#  AKTIEN-RISIKO-KENNZAHLEN  |  R
#  Volatilität  +  Value-at-Risk  +  Maximum Drawdown
#
#  Daniel Reiger
# ============================================================

# ---- Paket installieren (nur beim ersten Mal nötig) ----
if (!requireNamespace("quantmod", quietly = TRUE)) install.packages("quantmod")
library(quantmod)   # lädt Kursdaten von Yahoo Finance

# ============================================================
#  STEP 1: EINSTELLUNGEN  (hier kannst du alles ändern)
# ============================================================
ticker = "BMW.DE"   # welche Aktie?  z.B. SIE.DE, SAP.DE, ALV.DE
conf   = 0.95       # Konfidenzniveau für den VaR (95%)
jahre  = 2          # wie viele Jahre Historie?

# ============================================================
#  STEP 2: KURSDATEN LADEN
# ============================================================
message("Lade Kursdaten für ", ticker, " ...")
kurse = getSymbols(ticker, src = "yahoo",
                   from = Sys.Date() - 365 * jahre,
                   auto.assign = FALSE)
preise = as.numeric(Ad(kurse))   # Ad() = um Dividenden/Splits bereinigt

# ============================================================
#  STEP 3: TAGESRENDITEN BERECHNEN
# ============================================================
# Rendite = prozentuale Veränderung von einem Tag zum nächsten
renditen = diff(preise) / head(preise, -1)

# ============================================================
#  STEP 4: DIE DREI RISIKO-KENNZAHLEN
# ============================================================

# (1) VOLATILITÄT (annualisiert)
#     Standardabweichung der Tagesrenditen, hochgerechnet aufs Jahr.
#     252 = ungefähr die Anzahl Börsentage pro Jahr.
vola_taeglich = sd(renditen)
vola_jahr     = vola_taeglich * sqrt(252)

# (2) VALUE-AT-RISK (historisch)
#     Das schlechteste (1 - conf)-Quantil der echten Renditen.
#     Bei conf = 0.95 also das 5%-Quantil -> als Verlust positiv dargestellt.
VaR = -quantile(renditen, 1 - conf)

# (3) MAXIMUM DRAWDOWN
#     Größter Verlust von einem bisherigen Höchststand bis zum Tief.
hoechststand = cummax(preise)                 # laufendes Allzeithoch
drawdowns    = (preise - hoechststand) / hoechststand
max_drawdown = -min(drawdowns)                # als positive Zahl

# ============================================================
#  STEP 5: ERGEBNIS AUSGEBEN
# ============================================================
cat("\n", strrep("=", 45), "\n", sep = "")
cat("  RISIKO-REPORT:  ", ticker, "\n")
cat(strrep("=", 45), "\n", sep = "")
cat(sprintf("  Volatilität (p.a.):     %6.1f %%\n", vola_jahr * 100))
cat(sprintf("  Value-at-Risk (%g%%):    %6.1f %%   pro Tag\n",
            conf * 100, VaR * 100))
cat(sprintf("  Maximum Drawdown:       %6.1f %%\n", max_drawdown * 100))
cat(strrep("=", 45), "\n", sep = "")
cat("  Lesart: An 95% der Tage liegt der Tagesverlust\n")
cat("          unter dem VaR-Wert.\n\n")

# ============================================================
#  STEP 6: GRAFIK - Renditeverteilung mit VaR-Linie
# ============================================================
hist(renditen, breaks = 50, col = "#D6E4F0", border = "white",
     main = paste("Tagesrenditen:", ticker),
     xlab = "Tagesrendite", ylab = "Häufigkeit")
abline(v = -VaR, col = "#FF6600", lwd = 2, lty = 2)
legend("topleft", bty = "n",
       legend = paste0("VaR (", conf * 100, "%)"),
       col = "#FF6600", lwd = 2, lty = 2)
