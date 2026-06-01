# Aplikacija za praćenje i optimizaciju zaliha

Projekt izrađen u programskom jeziku R koristeći Shiny framework.

Funkcionalnosti

- Dodavanje proizvoda
- Uređivanje proizvoda
- Brisanje proizvoda
- Upozorenja o niskim zalihama
- Grafički prikaz stanja zaliha
- EOQ (Economic Order Quantity) optimizacija
- Spremanje i učitavanje podataka u CSV

Pokretanje

Potrebni paketi:

- shiny
- DT
- ggplot2
- shinyjs

Pokretanje:

```r
shiny::runApp("app.R")
