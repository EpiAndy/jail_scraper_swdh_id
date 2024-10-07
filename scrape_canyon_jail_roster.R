# Load necessary libraries
library(RSelenium)
library(rvest)
library(polite)
library(robotstxt)

# Define the URL
url <- "https://jailroster.canyoncounty.id.gov/"

# Extract the path
parsed_url <- parse_url(url)
path <- parsed_url$path
if (path == "") path <- "/"

# Check robots.txt permissions for the specific path
allowed <- paths_allowed(paths = path, domain = sprintf("%s://%s", parsed_url$scheme, parsed_url$hostname))
print(paste("Is scraping allowed for", path, ":", allowed))

if (allowed) {
  # Start RSelenium with Chrome
  rD <- rsDriver(browser = "chrome", port = 4545L, verbose = FALSE, chromever = "latest")
  remDr <- rD$client
  
  # Ensure Selenium server stops on script exit
  on.exit({
    remDr$close()
    rD$server$stop()
  }, add = TRUE)
  
  # Navigate to the website
  remDr$navigate(url)
  
  # Define a helper function for explicit wait
  wait_for_element <- function(driver, css_selector, timeout = 10) {
    for (i in 1:timeout) {
      elements <- driver$findElements(using = "css selector", value = css_selector)
      if (length(elements) > 0) {
        return(elements)
      }
      Sys.sleep(1)
    }
    stop(paste("Element with selector", css_selector, "not found within", timeout, "seconds"))
  }
  
  # Wait for the name links to load
  name_elements <- wait_for_element(remDr, ".name_link")
  
  # Extract page source after elements have loaded
  page_source <- remDr$getPageSource()[[1]]
  page <- read_html(page_source)
  
  # Extract names using the correct CSS selector
  names <- page %>% html_nodes(".name_link") %>% html_text(trim = TRUE)
  
  # Print the names
  print(names)
  
} else {
  message("Scraping is not allowed by the website's robots.txt")
}
