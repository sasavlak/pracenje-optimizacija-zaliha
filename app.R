library(shiny)
library(DT)
library(ggplot2)
library(shinyjs)

# Pocetni podaci
pocetni_podaci <- data.frame(
  Naziv = c("Monitor", "Tipkovnica", "Mis", "Laptop", "Printer papir"),
  Kategorija = c("IT oprema", "IT oprema", "IT oprema", "IT oprema", "Uredski materijal"),
  Cijena = c(180, 25, 15, 950, 8),
  Kolicina = c(5, 12, 20, 3, 50),
  Minimalna_kolicina = c(2, 5, 5, 2, 20),
  stringsAsFactors = FALSE
)

# Naziv CSV datoteke
csv_datoteka <- "zalihe_podaci.csv"

# Sifra za admin funkcije
admin_sifra <- "1234"

ui <- fluidPage(
  useShinyjs(),
  titlePanel("Aplikacija za praćenje i optimizaciju zaliha"),
  
  wellPanel(
    h4("Dobrodošli"),
    p("Ova aplikacija omogućuje unos, pregled, analizu i optimizaciju zaliha proizvoda."),
    p("Za početak unesite novi proizvod ili odaberite postojeći proizvod iz tablice za uređivanje."),
    p("Detaljne upute za korištenje dostupne su u kartici 'Početak rada'.")
  ),
  
  fluidRow(
    column(
      width = 4,
      wellPanel(
        h3("Unos i uređivanje proizvoda"),
        p("Unesite novi proizvod ili odaberite postojeći red u tablici za uređivanje."),
        
        textInput("naziv", "Naziv proizvoda", ""),
        textInput("kategorija", "Kategorija", ""),
        numericInput("cijena", "Cijena (€)", value = 0, step = 0.01),
        numericInput("kolicina", "Količina na skladištu", value = 0, step = 1),
        numericInput("minimalna", "Minimalna količina", value = 0, step = 1),
        
        helpText("Napomena: količina može biti i negativna ako je inventurom utvrđen manjak."),
        
        br(),
        
        fluidRow(
          column(6, actionButton("dodaj", "Dodaj proizvod", width = "100%")),
          column(6, actionButton("ocisti", "Očisti unos", width = "100%"))
        ),
        br(),
        fluidRow(
          column(6, actionButton("azuriraj", "Ažuriraj odabrani proizvod", width = "100%")),
          column(6, actionButton("obrisi", "Obriši odabrani proizvod", width = "100%"))
        ),
        
        br(), br(),
        
        h3("EOQ kalkulator"),
        p("EOQ se u ovoj verziji tumači na razini kategorije odabranog proizvoda."),
        
        h4("Odabrani proizvod"),
        textOutput("odabrani_proizvod"),
        
        h4("Odabrana kategorija"),
        textOutput("odabrana_kategorija"),
        
        br(),
        
        numericInput("godisnja_potraznja", "Godišnja potražnja kategorije (D)", value = 0, min = 0, step = 1),
        numericInput("trosak_narudzbe", "Trošak jedne narudžbe za kategoriju (S)", value = 0, min = 0, step = 0.01),
        numericInput("trosak_skladistenja", "Trošak skladištenja po jedinici godišnje (H)", value = 0, min = 0, step = 0.01),
        
        helpText("Unesite procijenjenu godišnju potražnju za odabranu kategoriju proizvoda, trošak jedne narudžbe te godišnji trošak skladištenja po jedinici proizvoda. Nakon promjene odabranog proizvoda EOQ polja se resetiraju."),
        
        actionButton("izracunaj_eoq", "Izračunaj EOQ", width = "100%"),
        br(), br(),
        verbatimTextOutput("eoq_rezultat")
      )
    ),
    
    column(
      width = 8,
      
      tabsetPanel(
        
        tabPanel(
          "Početak rada",
          
          br(),
          
          h2("Dobrodošli u aplikaciju za praćenje i optimizaciju zaliha"),
          
          p("Ova aplikacija omogućuje jednostavno upravljanje zalihama proizvoda, praćenje stanja skladišta, pregled upozorenja te optimizaciju narudžbi pomoću EOQ modela."),
          
          h3("Kako započeti?"),
          
          p("Za prvi rad s aplikacijom preporučuje se najprije dodati novi proizvod ili učitati postojeće podatke iz CSV datoteke. Nakon toga moguće je pregledati stanje zaliha, pratiti upozorenja o niskim zalihama, analizirati grafikone te koristiti EOQ kalkulator za planiranje optimalnih narudžbi."),
          
          hr(),
          
          h3("Koraci za korištenje aplikacije"),
          
          tags$ol(
            
            tags$li(
              strong("Dodavanje novog proizvoda"),
              br(),
              "U lijevom dijelu aplikacije unesite naziv proizvoda, kategoriju, cijenu, količinu na skladištu i minimalnu količinu.",
              br(),
              "Nakon unosa kliknite gumb 'Dodaj proizvod'."
            ),
            
            tags$li(
              strong("Pregled zaliha"),
              br(),
              "U kartici 'Pregled zaliha' prikazani su svi proizvodi koji se nalaze u sustavu.",
              br(),
              "Prikazani su i osnovni pokazatelji poput ukupnog broja proizvoda, ukupne količine artikala i ukupne vrijednosti zaliha."
            ),
            
            tags$li(
              strong("Uređivanje postojećeg proizvoda"),
              br(),
              "Kliknite na željeni red u tablici.",
              br(),
              "Podaci će se automatski učitati u obrazac za unos.",
              br(),
              "Nakon izmjene kliknite 'Ažuriraj odabrani proizvod'."
            ),
            
            tags$li(
              strong("Brisanje proizvoda"),
              br(),
              "Odaberite proizvod u tablici i kliknite 'Obriši odabrani proizvod'.",
              br(),
              "Prije brisanja prikazat će se sigurnosna potvrda."
            ),
            
            tags$li(
              strong("Praćenje upozorenja"),
              br(),
              "Kartica 'Upozorenja o stanju' prikazuje proizvode čija je količina manja od definirane minimalne količine.",
              br(),
              "Na taj način moguće je pravovremeno planirati novu narudžbu."
            ),
            
            tags$li(
              strong("Analiza grafikona"),
              br(),
              "Kartica 'Grafikoni' prikazuje vrijednost zaliha po kategorijama, količine proizvoda po kategorijama te proizvode kojima nedostaje zaliha do minimalne razine."
            ),
            
            tags$li(
              strong("Optimizacija zaliha pomoću EOQ modela"),
              br(),
              "Najprije odaberite proizvod u tablici.",
              br(),
              "Unesite godišnju potražnju, trošak jedne narudžbe i trošak skladištenja.",
              br(),
              "Klikom na 'Izračunaj EOQ' aplikacija izračunava optimalnu količinu narudžbe, broj potrebnih narudžbi godišnje i procijenjene godišnje troškove."
            ),
            
            tags$li(
              strong("Spremanje i učitavanje podataka"),
              br(),
              "U kartici 'Administracija' moguće je spremiti podatke u CSV datoteku ili učitati prethodno spremljene podatke."
            )
          ),
          
          hr(),
          
          h3("Napomena"),
          
          p("Količina proizvoda može biti i negativna ako je tijekom inventure utvrđen manjak u odnosu na očekivano stanje skladišta."),
          
          p("Administrativne funkcije poput vraćanja početnog stanja i brisanja svih podataka zaštićene su lozinkom."),
          
          hr(),
          
          h3("Dokumentacija projekta"),
          
          p("Izvorni kod i online verzija aplikacije dostupni su putem sljedećih poveznica:"),
          
          tags$a(
            href = "https://github.com/sasavlak/pracenje-optimizacija-zaliha.git",
            target = "_blank",
            class = "btn btn-default",
            "GitHub repozitorij"
          ),
    
        ),
        
        tabPanel(
          tagList(icon("boxes-stacked"), " Pregled zaliha"),
          br(),
          fluidRow(
            column(
              3,
              wellPanel(
                h4("Ukupan broj proizvoda"),
                textOutput("broj_proizvoda")
              )
            ),
            
            column(
              3,
              wellPanel(
                h4("Ukupna količina artikala"),
                textOutput("ukupna_kolicina")
              )
            ),
            
            column(
              3,
              wellPanel(
                h4("Ukupna vrijednost zaliha"),
                textOutput("ukupna_vrijednost")
              )
            ),
            
            column(
              3,
              wellPanel(
                h4("Proizvodi ispod minimuma"),
                textOutput("broj_kriticnih")
              )
            )
          ),
          p("Klikom na red u tablici proizvod se učitava u formu za uređivanje."),
          DTOutput("tablica")
        ),
        
        tabPanel(
          "Upozorenja o stanju",
          br(),
          h4("Proizvodi ispod minimalne razine zaliha"),
          p("Ovdje su prikazani proizvodi čija je količina manja od minimalno definirane količine."),
          
          htmlOutput("upozorenje_broj"),
          
          tableOutput("upozorenja")
        ),
        
        tabPanel(
          "Grafikoni",
          br(),
          p("U nastavku su prikazani osnovni grafički pokazatelji stanja zaliha."),
          h4("Vrijednost zaliha po kategorijama"),
          plotOutput("graf_vrijednost_kategorije"),
          br(),
          h4("Količina zaliha po kategorijama"),
          plotOutput("graf_kolicina_kategorije"),
          br(),
          h4("Nedostajuća količina do minimalne razine"),
          plotOutput("graf_nedostaje")
        ),
        
        tabPanel(
          "Optimizacija zaliha",
          br(),
          h4("Objašnjenje"),
          p("EOQ model (Economic Order Quantity) koristi se za izračun optimalne količine narudžbe kako bi se smanjili troškovi naručivanja i skladištenja."),
          p("Rezultat je prikazan za kategoriju odabranog proizvoda. Aplikacija izračunava optimalnu količinu narudžbe (EOQ), procijenjeni broj narudžbi godišnje, godišnji trošak naručivanja, godišnji trošak skladištenja te ukupni godišnji trošak upravljanja zalihama."),
          p("Na grafikonu je prikazan ukupni trošak za različite količine narudžbe. Najniža točka krivulje predstavlja optimalnu količinu narudžbe, odnosno EOQ."),
          br(),
          textOutput("poruka_graf_eoq"),
          plotOutput("graf_eoq")
        ),
        
        tabPanel(
          "Administracija",
          br(),
          h3("Spremanje i učitavanje podataka"),
          
          downloadButton("preuzmi_csv", "Preuzmi CSV datoteku", width = "100%"),
          br(), br(),
          fileInput("ucitaj_csv", "Odaberi CSV datoteku", width = "100%"),
          
          br(), br(),
          h3("Zaštićene funkcije"),
          passwordInput("admin_lozinka", "Unesi šifru za administraciju", value = ""),
          
          actionButton("vrati_pocetno", "Vrati na početno stanje", class = "btn-danger", width = "100%"),
          br(), br(),
          actionButton("obrisi_sve", "Obriši sve iz baze", class = "btn-danger", width = "100%"),
          
          br(), br(),
          verbatimTextOutput("admin_poruka")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  zalihe <- reactiveVal(pocetni_podaci)
  admin_rezultat <- reactiveVal("")
  odabrani_red <- reactiveVal(NULL)
  eoq_poruka <- reactiveVal("")
  tablica_proxy <- dataTableProxy("tablica")
  
  # Funkcija za ciscenje forme
  ocisti_formu <- function() {
    updateTextInput(session, "naziv", value = "")
    updateTextInput(session, "kategorija", value = "")
    updateNumericInput(session, "cijena", value = 0)
    updateNumericInput(session, "kolicina", value = 0)
    updateNumericInput(session, "minimalna", value = 0)
  }
  
  # Reset EOQ polja
  reset_eoq_polja <- function() {
    updateNumericInput(session, "godisnja_potraznja", value = 0)
    updateNumericInput(session, "trosak_narudzbe", value = 0)
    updateNumericInput(session, "trosak_skladistenja", value = 0)
  }
  
  # Reset EOQ poruke
  reset_eoq_rezultat <- function() {
    eoq_poruka("")
  }
  
  # Izlazak iz moda uredjivanja
  izlaz_iz_uredjivanja <- function() {
    selectRows(tablica_proxy, NULL)
    odabrani_red(NULL)
    enable("dodaj")
    reset_eoq_polja()
    reset_eoq_rezultat()
  }
  
  # Provjera admin sifre
  provjeri_sifru <- function() {
    unesena_sifra <- input$admin_lozinka
    
    updateTextInput(session, "admin_lozinka", value = "")
    
    if (unesena_sifra != admin_sifra) {
      admin_rezultat("Pogrešna šifra, radnja nije dopuštena.")
      return(FALSE)
    }
    
    return(TRUE)
  }
  
  # Dodavanje novog proizvoda
  observeEvent(input$dodaj, {
    if (trimws(input$naziv) == "" || trimws(input$kategorija) == "") {
      showNotification("Naziv i kategorija moraju biti uneseni.", type = "error")
      return()
    }
    
    novi_red <- data.frame(
      Naziv = input$naziv,
      Kategorija = input$kategorija,
      Cijena = input$cijena,
      Kolicina = input$kolicina,
      Minimalna_kolicina = input$minimalna,
      stringsAsFactors = FALSE
    )
    
    novi_podaci <- rbind(zalihe(), novi_red)
    zalihe(novi_podaci)
    
    ocisti_formu()
    izlaz_iz_uredjivanja()
    
    showNotification("Proizvod je uspješno dodan.", type = "message")
  })
  
  # Ciscenje forme + izlazak iz uredjivanja
  observeEvent(input$ocisti, {
    ocisti_formu()
    izlaz_iz_uredjivanja()
    showNotification("Polja za unos su očišćena i odabir u tablici je uklonjen.", type = "message")
  })
  
  # Odabir reda u tablici
  observeEvent(input$tablica_rows_selected, {
    red <- input$tablica_rows_selected
    
    if (!is.null(red) && length(red) > 0) {
      podaci <- zalihe()
      
      if (red <= nrow(podaci)) {
        odabrani_red(red)
        
        updateTextInput(session, "naziv", value = podaci$Naziv[red])
        updateTextInput(session, "kategorija", value = podaci$Kategorija[red])
        updateNumericInput(session, "cijena", value = podaci$Cijena[red])
        updateNumericInput(session, "kolicina", value = podaci$Kolicina[red])
        updateNumericInput(session, "minimalna", value = podaci$Minimalna_kolicina[red])
        
        reset_eoq_polja()
        reset_eoq_rezultat()
        
        disable("dodaj")
      }
    }
  })
  
  # Azuriranje odabranog proizvoda
  observeEvent(input$azuriraj, {
    red <- input$tablica_rows_selected
    
    if (is.null(red) || length(red) == 0) {
      showNotification("Prvo odaberi proizvod u tablici.", type = "error")
      return()
    }
    
    if (trimws(input$naziv) == "" || trimws(input$kategorija) == "") {
      showNotification("Naziv i kategorija ne smiju biti prazni.", type = "error")
      return()
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      showNotification("Odabrani red više ne postoji.", type = "error")
      return()
    }
    
    podaci$Naziv[red] <- input$naziv
    podaci$Kategorija[red] <- input$kategorija
    podaci$Cijena[red] <- input$cijena
    podaci$Kolicina[red] <- input$kolicina
    podaci$Minimalna_kolicina[red] <- input$minimalna
    
    naziv_azuriranog <- input$naziv
    
    zalihe(podaci)
    replaceData(tablica_proxy, zalihe(), resetPaging = FALSE, rownames = FALSE)
    
    showNotification(
      paste("Proizvod", naziv_azuriranog, "je uspješno ažuriran."),
      type = "message"
    )
  })
  
  # Brisanje odabranog proizvoda
  observeEvent(input$obrisi, {
    red <- input$tablica_rows_selected
    
    if (is.null(red) || length(red) == 0) {
      showNotification("Prvo odaberi proizvod u tablici.", type = "error")
      return()
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      showNotification("Odabrani red više ne postoji.", type = "error")
      return()
    }
    
    naziv_proizvoda <- podaci$Naziv[red]
    
    showModal(modalDialog(
      title = "Potvrda brisanja",
      tagList(
        span("Jeste li sigurni da želite obrisati proizvod: "),
        strong(naziv_proizvoda),
        span("?"),
        br(), br(),
        span("Ova radnja će ukloniti proizvod iz baze podataka.")
      ),
      footer = tagList(
        modalButton("Odustani"),
        actionButton("potvrdi_brisanje", "Da, obriši proizvod", class = "btn-danger")
      ),
      easyClose = FALSE
    ))
  })
  
  observeEvent(input$potvrdi_brisanje, {
    red <- input$tablica_rows_selected
    
    if (is.null(red) || length(red) == 0) {
      removeModal()
      showNotification("Nijedan proizvod nije odabran.", type = "error")
      return()
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      removeModal()
      showNotification("Odabrani red više ne postoji.", type = "error")
      return()
    }
    
    podaci <- podaci[-red, , drop = FALSE]
    zalihe(podaci)
    
    ocisti_formu()
    izlaz_iz_uredjivanja()
    removeModal()
    
    showNotification("Odabrani proizvod je obrisan.", type = "message")
  })
  
  # Spremanje u CSV
  observeEvent(input$spremi_csv, {
    write.csv(zalihe(), csv_datoteka, row.names = FALSE, fileEncoding = "UTF-8")
    admin_rezultat(paste("Podaci su spremljeni u datoteku:", csv_datoteka))
    showNotification("Podaci su uspješno spremljeni u CSV.", type = "message")
  })
  
  # Ucitavanje iz CSV
  observeEvent(input$ucitaj_csv, {
    
    req(input$ucitaj_csv)
    
    ucitani_podaci <- read.csv(
      input$ucitaj_csv$datapath,
      stringsAsFactors = FALSE,
      fileEncoding = "UTF-8"
    )
    
    potrebni_stupci <- c(
      "Naziv",
      "Kategorija",
      "Cijena",
      "Kolicina",
      "Minimalna_kolicina"
    )
    
    if (!all(potrebni_stupci %in% names(ucitani_podaci))) {
      
      admin_rezultat("CSV datoteka nema ispravnu strukturu.")
      
      showNotification(
        "CSV datoteka nema ispravnu strukturu.",
        type = "error"
      )
      
      return()
    }
    
    zalihe(ucitani_podaci)
    
    ocisti_formu()
    izlaz_iz_uredjivanja()
    
    admin_rezultat("Podaci su uspješno učitani iz CSV datoteke.")
    
    showNotification(
      "Podaci su uspješno učitani.",
      type = "message"
    )
  })
  
  # Vracanje na pocetno stanje
  observeEvent(input$vrati_pocetno, {
    if (!provjeri_sifru()) {
      showNotification("Pogrešna šifra za reset.", type = "error")
      return()
    }
    
    zalihe(pocetni_podaci)
    ocisti_formu()
    izlaz_iz_uredjivanja()
    
    admin_rezultat("Aplikacija je vraćena na početno stanje.")
    showNotification("Početni podaci su vraćeni.", type = "message")
  })
  
  # Brisanje svega iz baze
  observeEvent(input$obrisi_sve, {
    if (!provjeri_sifru()) {
      showNotification("Pogrešna šifra za brisanje baze.", type = "error")
      return()
    }
    
    prazna_baza <- data.frame(
      Naziv = character(),
      Kategorija = character(),
      Cijena = numeric(),
      Kolicina = numeric(),
      Minimalna_kolicina = numeric(),
      stringsAsFactors = FALSE
    )
    
    zalihe(prazna_baza)
    ocisti_formu()
    izlaz_iz_uredjivanja()
    
    admin_rezultat("Svi podaci iz baze su obrisani.")
    showNotification("Baza je ispražnjena.", type = "message")
  })
  
  # Tablica
  output$tablica <- renderDT({
    datatable(
      zalihe(),
      selection = "single",
      rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE)
    )
  })
  
  # Prikaz odabranog proizvoda
  output$odabrani_proizvod <- renderText({
    red <- odabrani_red()
    
    if (is.null(red)) {
      return("Nije odabran proizvod")
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      return("Nije odabran proizvod")
    }
    
    paste("Odabrani proizvod:", podaci$Naziv[red])
  })
  
  # Prikaz odabrane kategorije
  output$odabrana_kategorija <- renderText({
    red <- odabrani_red()
    
    if (is.null(red)) {
      return("Nije odabrana kategorija")
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      return("Nije odabrana kategorija")
    }
    
    paste("Kategorija:", podaci$Kategorija[red])
  })
  
  # Sažeti pokazatelji
  output$broj_proizvoda <- renderText({
    nrow(zalihe())
  })
  
  output$ukupna_kolicina <- renderText({
    if (nrow(zalihe()) == 0) {
      return(0)
    }
    sum(zalihe()$Kolicina)
  })
  
  output$ukupna_vrijednost <- renderText({
    if (nrow(zalihe()) == 0) {
      return("0 €")
    }
    
    ukupno <- sum(zalihe()$Cijena * zalihe()$Kolicina)
    paste(round(ukupno, 2), "€")
  })
  
  output$broj_kriticnih <- renderText({
    
    podaci <- zalihe()
    
    if (nrow(podaci) == 0) {
      return(0)
    }
    
    sum(
      podaci$Kolicina < podaci$Minimalna_kolicina
    )
    
  })
  # Crveno/zeleno upozorenje iznad tablice
  output$upozorenje_broj <- renderUI({
    
    podaci <- zalihe()
    
    kriticni <- podaci[
      podaci$Kolicina < podaci$Minimalna_kolicina,
      ,
      drop = FALSE
    ]
    
    if (nrow(kriticni) == 0) {
      
      HTML(
        "<div style='color:green; font-weight:bold; font-size:16px;'>
      ✓ Trenutno nema proizvoda ispod minimalne razine zaliha.
      </div>"
      )
      
    } else {
      
      HTML(
        paste0(
          "<div style='color:red; font-weight:bold; font-size:18px;'>
        Upozorenje: ",
          nrow(kriticni),
          " proizvoda nalazi se ispod minimalne razine zaliha.
        </div>"
        )
      )
      
    }
  })
  
  # Upozorenja
  output$upozorenja <- renderTable({
    podaci <- zalihe()
    
    if (nrow(podaci) == 0) {
      return(data.frame(Poruka = "Baza je prazna."))
    }
    
    rezultat <- podaci[podaci$Kolicina < podaci$Minimalna_kolicina, , drop = FALSE]
    
    if (nrow(rezultat) == 0) {
      data.frame(Poruka = "Nema proizvoda ispod minimalne razine zaliha.")
    } else {
      rezultat
    }
  })
  
  # Graf 1 - vrijednost po kategorijama
  output$graf_vrijednost_kategorije <- renderPlot({
    podaci <- zalihe()
    
    if (nrow(podaci) == 0) {
      return(NULL)
    }
    
    podaci$Vrijednost <- podaci$Cijena * podaci$Kolicina
    sazetak <- aggregate(Vrijednost ~ Kategorija, data = podaci, sum)
    
    ggplot(sazetak, aes(x = Kategorija, y = Vrijednost, fill = Kategorija)) +
      geom_bar(stat = "identity") +
      labs(
        title = "Vrijednost zaliha po kategorijama",
        x = "Kategorija",
        y = "Vrijednost (€)"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Graf 2 - kolicina po kategorijama
  output$graf_kolicina_kategorije <- renderPlot({
    podaci <- zalihe()
    
    if (nrow(podaci) == 0) {
      return(NULL)
    }
    
    sazetak <- aggregate(Kolicina ~ Kategorija, data = podaci, sum)
    
    ggplot(sazetak, aes(x = Kategorija, y = Kolicina, fill = Kategorija)) +
      geom_bar(stat = "identity") +
      labs(
        title = "Količina zaliha po kategorijama",
        x = "Kategorija",
        y = "Količina"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  # Graf 3 - koliko nedostaje do minimuma
  output$graf_nedostaje <- renderPlot({
    podaci <- zalihe()
    
    if (nrow(podaci) == 0) {
      return(NULL)
    }
    
    podaci$Nedostaje <- ifelse(
      podaci$Kolicina < podaci$Minimalna_kolicina,
      podaci$Minimalna_kolicina - podaci$Kolicina,
      0
    )
    
    podaci_nedostaje <- podaci[podaci$Nedostaje > 0, , drop = FALSE]
    
    if (nrow(podaci_nedostaje) == 0) {
      return(NULL)
    }
    
    ggplot(podaci_nedostaje, aes(x = reorder(Naziv, Nedostaje), y = Nedostaje, fill = Kategorija)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(
        title = "Nedostajuća količina do minimalne razine",
        x = "Proizvod",
        y = "Nedostajuća količina"
      ) +
      theme_minimal()
  })
  
  # EOQ izracun za kategoriju odabranog proizvoda
  observeEvent(input$izracunaj_eoq, {
    red <- odabrani_red()
    
    if (is.null(red)) {
      eoq_poruka("Prvo odaberite proizvod u tablici.")
      return()
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      eoq_poruka("Prvo odaberite proizvod u tablici.")
      return()
    }
    
    D <- input$godisnja_potraznja
    S <- input$trosak_narudzbe
    H <- input$trosak_skladistenja
    
    if (D <= 0 || S <= 0 || H <= 0) {
      eoq_poruka("Za EOQ izračun unesite vrijednosti veće od 0.")
      return()
    }
    
    kategorija <- podaci$Kategorija[red]
    eoq <- sqrt((2 * D * S) / H)
    broj_narudzbi <- D / eoq
    godisnji_trosak_narucivanja <- broj_narudzbi * S
    godisnji_trosak_skladistenja <- (eoq / 2) * H
    ukupni_godisnji_trosak <- godisnji_trosak_narucivanja + godisnji_trosak_skladistenja
    
    eoq_poruka(
      paste(
        "Kategorija:", kategorija, "\n",
        "Optimalna količina narudžbe (EOQ):", round(eoq, 2), "jedinica\n",
        "Broj narudžbi godišnje:", round(broj_narudzbi, 2), "\n",
        "Godišnji trošak naručivanja:", round(godisnji_trosak_narucivanja, 2), "€\n",
        "Godišnji trošak skladištenja:", round(godisnji_trosak_skladistenja, 2), "€\n",
        "Ukupni godišnji trošak:", round(ukupni_godisnji_trosak, 2), "€"
      )
    )
  })
  
  output$eoq_rezultat <- renderText({
    eoq_poruka()
  })
  
  output$poruka_graf_eoq <- renderText({
    red <- odabrani_red()
    
    if (is.null(red)) {
      return("Za prikaz EOQ grafa odaberite proizvod i unesite vrijednosti veće od 0.")
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      return("Za prikaz EOQ grafa odaberite proizvod i unesite vrijednosti veće od 0.")
    }
    
    D <- input$godisnja_potraznja
    S <- input$trosak_narudzbe
    H <- input$trosak_skladistenja
    
    if (D <= 0 || S <= 0 || H <= 0) {
      return("Za prikaz EOQ grafa odaberite proizvod i unesite vrijednosti veće od 0.")
    }
    
    return("")
  })
  
  # EOQ graf
  output$graf_eoq <- renderPlot({
    red <- odabrani_red()
    
    if (is.null(red)) {
      return(NULL)
    }
    
    podaci <- zalihe()
    
    if (red > nrow(podaci)) {
      return(NULL)
    }
    
    D <- input$godisnja_potraznja
    S <- input$trosak_narudzbe
    H <- input$trosak_skladistenja
    
    if (D <= 0 || S <= 0 || H <= 0) {
      return(NULL)
    }
    
    kategorija <- podaci$Kategorija[red]
    eoq <- sqrt((2 * D * S) / H)
    
    max_q <- max(ceiling(eoq * 2), 10)
    kolicina_narudzbe <- seq(1, max_q, by = 1)
    
    trosak_narucivanja <- (D / kolicina_narudzbe) * S
    trosak_skladistenja <- (kolicina_narudzbe / 2) * H
    ukupni_trosak <- trosak_narucivanja + trosak_skladistenja
    
    graf_podaci <- data.frame(
      Kolicina = kolicina_narudzbe,
      Ukupni_trosak = ukupni_trosak
    )
    
    indeks_min <- which.min(graf_podaci$Ukupni_trosak)
    min_x <- graf_podaci$Kolicina[indeks_min]
    min_y <- graf_podaci$Ukupni_trosak[indeks_min]
    
    ggplot(graf_podaci, aes(x = Kolicina, y = Ukupni_trosak)) +
      geom_line(linewidth = 1) +
      geom_vline(xintercept = eoq, linetype = "dashed") +
      geom_point(aes(x = min_x, y = min_y), size = 3) +
      labs(
        title = paste("EOQ graf za kategoriju:", kategorija),
        x = "Količina narudžbe",
        y = "Ukupni trošak"
      ) +
      theme_minimal()
  })
  
  # Preuzimanje CSV datoteke
  output$preuzmi_csv <- downloadHandler(
    
    filename = function() {
      paste0("zalihe_", Sys.Date(), ".csv")
    },
    
    content = function(file) {
      write.csv(
        zalihe(),
        file,
        row.names = FALSE,
        fileEncoding = "UTF-8"
      )
    }
  )
  
  # Admin poruka
  output$admin_poruka <- renderText({
    admin_rezultat()
  })
}

shinyApp(ui = ui, server = server)