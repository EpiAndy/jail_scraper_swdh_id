library(rvest)
library(httr2)

# Initialize an empty data frame to store all names
washington_all_names_df <- data.frame(Name = character())

# Define the initial URL
base_url <- "https://washington-so-id.zuercherportal.com/"

# Set up a repeat loop to continue scraping while the "Next" button is available
repeat {
  
  # Make the request to the current page
  response <- request(base_url) |>
    req_headers(
      Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0"
    ) |>
    req_perform()
  
  # Parse the HTML content of the response
  page <- resp_body_html(response)
  
  # Debug: Print the structure of the HTML to find the correct selectors
  print(page)  # This will give you a large amount of HTML output; use this to find the correct elements
  
  # Alternatively, print the specific table or other sections you want to inspect
  print(html_nodes(page, "table"))  # Adjust this based on the relevant structure
  
  # Extract names from the first column of each row in the table (adjust the selector as needed)
  names <- page %>%
    html_nodes("td.ordered-tag") %>%  # Update this selector based on actual structure
    html_text(trim = TRUE)
  
  # Debugging: Print extracted names to verify
  print(names)
  
  # If no names are found, stop the loop
  if (length(names) == 0) {
    cat("No more names found, stopping the loop.\n")
    break
  }
  
  # Convert the extracted names into a data frame
  names_df <- data.frame(Name = names)
  
  # Append the extracted names to the main data frame
  washington_all_names_df <- rbind(washington_all_names_df, names_df)
  
  # Output message for each iteration
  cat("Names have been extracted.\n")
  
  # Find the "Next" button link based on the provided selector
  next_button <- page %>%
    html_node(".btn")  # This selector might need to be updated based on HTML structure
  
  # Check if the "Next" button is present and enabled
  if (is.null(next_button)) {
    cat("No 'Next' button found or it is disabled, stopping the loop.\n")
    break
  }
  
  # Extract the pagination link or action from the "Next" button
  next_page_link <- next_button %>%
    html_attr("onclick")
  
  # Debugging: Print the next page link to ensure it's correct
  print(next_page_link)
  
  # If no next page link is found, stop the loop
  if (is.na(next_page_link) || is.null(next_page_link)) {
    cat("No 'Next' page link found, stopping the loop.\n")
    break
  }
  
  # Update the base URL for the next iteration
  base_url <- url_absolute(next_page_link, base_url)
}

# Save all the names to a CSV file after the loop completes
write.csv(washington_all_names_df, "washington_all_extracted_names.csv", row.names = FALSE)

# Final message
cat("Completed extraction for all pages and saved to washington_all_extracted_names.csv.\n")
