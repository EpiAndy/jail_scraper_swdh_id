# Install necessary packages
install.packages("RSelenium")
install.packages("rvest")
install.packages("polite")

# Load the libraries
library(RSelenium)
library(rvest)
library(polite)

# Start RSelenium
rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE)
remDr <- rD$client

# Use polite to check the website's robots.txt
session <- bow("https://jailroster.canyoncounty.id.gov/")

# Navigate to the website if allowed
if (session$robots$permissions$allowed) {
  remDr$navigate("https://jailroster.canyoncounty.id.gov/")
  
  # Give the page some time to load
  Sys.sleep(5)
  
  # Extract the page source
  page_source <- remDr$getPageSource()[[1]]
  
  # Parse the page source with rvest
  page <- read_html(page_source)
  
  # Extract names under the class "name_link"
  names <- page %>% html_nodes(".name_link") %>% html_text()
  
  # Print the names
  print(names)
  
  # Close the RSelenium client
  remDr$close()
  rD$server$stop()
} else {
  message("Scraping is not allowed by the website's robots.txt")
}
