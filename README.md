# Inventory Tracking and Optimization Application Using the Shiny Web Application
# Aplikacija za praćenje i optimizaciju zaliha

Projekt izrađen u programskom jeziku R koristeći Shiny framework.

U današnjem poslovnom okruženju učinkovito upravljanje zalihama ključno je za održavanje stabilnog poslovanja i smanjenje troškova. 
Mala i srednja poduzeća često nemaju pristup skupim ERP sustavima, stoga im je potrebna jednostavna i intuitivna aplikacija za praćenje i analizu stanja zaliha. 
Ovaj projekt ima za cilj razviti web-aplikaciju izrađenu u R i Shiny okruženju koja omogućuje korisnicima unos, pregled i analizu podataka o zalihama na jednostavan i interaktivan način. 

Funkcionalnosti

- Dodavanje proizvoda
- Uređivanje proizvoda
- Brisanje proizvoda
- Upozorenja o niskim zalihama
- Grafički prikaz stanja zaliha
- EOQ (Economic Order Quantity) optimizacija
- Spremanje i učitavanje podataka u CSV

Pokretanje

Potrebni paketi u R:

- shiny
- DT
- ggplot2
- shinyjs

Pokretanje lokalno u R:

shiny::runApp("app.R")

Online aplikacija:
https://svlak.shinyapps.io/pracenje-optimizacija-zaliha/
