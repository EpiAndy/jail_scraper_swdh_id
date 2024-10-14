# Load necessary libraries
library(RSelenium)
library(rvest)

# Start RSelenium (Previous error and Chat says to make sure you have Java installed and the appropriate Selenium server)
rD <- rsDriver(remoteServerAddr = "localhost", browser = "firefox", port = 4445L, verbose = FALSE, chromever = NULL)
remDr <- rD$client

# Open the remote driver
remDr$open() 

# Scrape the names for a given letter
scrape_names <- function(letter) {
  # Go to the webpage
  url <- "https://jailroster.canyoncounty.id.gov/"
  remDr$navigate(url)
  
  # Find the search bar and enter a letter
  search_bar <- remDr$findElement(using = "css", "#input")  
  search_bar$sendKeysToElement(list(letter))
  
  # Click the search button
  search_button <- remDr$findElement(using = "css", "#button")
  search_button$clickElement()
  
  # Wait for page to load
  Sys.sleep(3)
  
  # Define page with names
  page_source <- remDr$getPageSource()[[1]]
  page <- read_html(page_source)
  
  # Find the name and scrape them
  names <- page %>%
    html_nodes("a.name") %>%
    html_text()
  
  return(names)
}

# Loop over all letters of the alphabet
alphabet <- LETTERS
all_names <- list()

for (letter in alphabet) {
  cat("Scraping names:", letter, "\n")
  names <- scrape_names(letter)
  all_names[[letter]] <- names
}

# Combine the names into a dataframe
combined_names <- unlist(all_names)

# Save
write.csv(combined_names, "names_scraped.csv")

# Stop the RSelenium session
remDr$close()
rD$server$stop()