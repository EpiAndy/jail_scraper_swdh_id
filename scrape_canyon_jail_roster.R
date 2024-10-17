library(rvest)
library(httr2)

# Define a vector of the alphabet
alphabet <- letters  # Generates a vector from "a" to "z"

# Initialize an empty data frame to store all names
canyon_all_names_df <- data.frame(Name = character())

# Loop through each letter in the alphabet
for (letter in alphabet) {
  
  # Make the POST request with the current letter in the search bar
  response <- request("https://jailroster.canyoncounty.id.gov/Roster/GetListByLetter") |>
    req_method("POST") |>
    req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9",
      cookie = "_gid=GA1.2.661660723.1729175046; _ga_K8KEJYLE4K=GS1.1.1729178161.2.1.1729178166.0.0.0; .AspNetCore.Antiforgery.q8fc4Vga5g0=CfDJ8C8N8t58tP9CkonDaN_nLxX4S3BLCiB9WfTh1-dCHVUNBHro4HVSH7o4bWPW1pMOWru3EWmDUgNmqEMp8TJ5KuDhmA_zQNrF0GteS3opJXBrkBHrcztzstGyAXy3aW2dz2xAofANf3AZYt9kNxZxFLI; .AspNetCore.Session=CfDJ8C8N8t58tP9CkonDaN%2FnLxX%2FDSfcB3gx5QOFYNwXiv2OJ8Za82orZI6y3U5C%2BbOr863y3lLDcuZYxUrfsNmy%2Bafn85k9iXLGlSv%2FvUsWJbRIy1dHLgbdIvLRueq68iNZOIcEGSyv048BfVd%2Bg%2B1cNwwPCU7FOi31AUw%2BbFbi2DjW; _ga_P9YH8603V3=GS1.1.1729178381.1.0.1729178381.0.0.0; _ga=GA1.1.116006209.1729175046",
      dnt = "1",
      origin = "https://jailroster.canyoncounty.id.gov",
      priority = "u=1, i",
      referer = "https://jailroster.canyoncounty.id.gov/",
      requestverificationtoken = "CfDJ8C8N8t58tP9CkonDaN_nLxWcgXGjCwDg0LvETXAV27K3fnUFLbG28uMSg4k-6mKvR-FS2thJ1qMfJfjd7A4s8Ocd7e6l6hlaxQpyNN6aLFyEGW584BdJXgmQVZCrDWuZN6s38RS-pld7cCybYKJTQvA",
      `sec-ch-ua` = '"Microsoft Edge";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "empty",
      `sec-fetch-mode` = "cors",
      `sec-fetch-site` = "same-origin",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0",
      `x-requested-with` = "XMLHttpRequest"
    ) |>
    req_body_form(letter = letter) |>
    req_perform()
  
  # Parse the response
  page <- resp_body_html(response)
  
  # Extract names using the .name_link class (adjust based on actual structure)
  names <- page %>%
    html_nodes(".name_link") %>%  # Use the correct selector
    html_text(trim = TRUE)
  
  # Convert the extracted names into a data frame
  names_df <- data.frame(Name = names)
  
  # Append the extracted names to the main data frame
  canyon_all_names_df <- rbind(canyon_all_names_df, names_df)
  
  # Output message for each iteration
  cat("Names for letter", letter, "have been extracted.\n")
}

# Save all the names to a single CSV file after the loop completes
write.csv(all_names_df, "canyon_all_extracted_names.csv", row.names = FALSE)

# Final message
cat("Completed extraction for all letters of the alphabet and saved to canyon_all_extracted_names.csv.\n")
