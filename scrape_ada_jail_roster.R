library(rvest)
library(httr2)

# Define a vector of the alphabet
alphabet <- letters  # Generates a vector from "a" to "z"

# Initialize an empty data frame to store all names
ada_all_names_df <- data.frame(Name = character())

# Loop through each letter in the alphabet
for (letter in alphabet) {
  
  # Make the POST request with the current letter in the search bar
  response <- request("https://apps.adacounty.id.gov/sheriff/reports/inmates.aspx") |>
    req_method("POST") |>
    req_headers(
      accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
      `accept-language` = "en-US,en;q=0.9",
      `cache-control` = "max-age=0",
      cookie = "__cf_bm=dVSj_bcCLaKngUI4f_4PbVVI3AL.R5SjdQgptOElw0A-1729175045-1.0.1.1-pwSvXxp2jywrTECOc4ObuAPfUACTCx_DbRr6M_g_mCCTFosUjS228IFxdAmS9sLIb3WgmLtYFf09dhc1sgB2zw; __cflb=02DiuFM1b9qouwr15fzcJp79odAzrLxxtfpUqagrkXPWU; _gid=GA1.2.661660723.1729175046; _gat_gtag_UA_21779422_5=1; cf_clearance=A1hItbB95.UJoOD3S_CZKZpkeDz0qKUHWHNNBY728dM-1729175861-1.2.1.1-ZFbL57XA6Dq6l7S1AkC_H5RJvzrtaRb5r7sjO.6njhuiMQ32.iDazZHGroJWY9JLoogUPuRhqNAW6J8GyvoRpWJ4UUCdv..qayVTSwi_1kL6YzBPyd4UF_0xQGHITyvaA2t.8Cu_D__CvjTtzc6LteZA8NT8Qd6zQTD5BgpRjjSFwFmQuo8ihA0nypvDlPYw3SaLQEAO1Ypzn4ZZDdHK9pNwfHgKijh1D7.kCsX5YRMAA5_KUz.j.IjqN_KnlO9bPIQUC8SGxYLeKvUbyQjVCU0zR_JUQjHjtLSlbw6G33emQsUnPe3VQ_c5.zA5fFoS8EbiQKBYjyrYQIqFqd1TsSgO54tqJhSUQeUMJjAjyLF6mlqUh6HCeNxFvvoJo3oU5H14w0vR9Yfa8y6agS5agQ; _ga=GA1.1.116006209.1729175046; _ga_K8KEJYLE4K=GS1.1.1729175045.1.1.1729175877.0.0.0",
      dnt = "1",
      origin = "https://apps.adacounty.id.gov",
      priority = "u=0, i",
      referer = "https://apps.adacounty.id.gov/sheriff/reports/inmates.aspx",
      `sec-ch-ua` = '"Microsoft Edge";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "document",
      `sec-fetch-mode` = "navigate",
      `sec-fetch-site` = "same-origin",
      `sec-fetch-user` = "?1",
      `upgrade-insecure-requests` = "1",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0"
    ) |>
    req_body_form(
      `__EVENTTARGET` = "ctl00$ContentPlaceHolder1$btnFilter",
      `__EVENTARGUMENT` = "",
      `__VIEWSTATE` = "OIUxRfAIa8n2nA2+SG1Mjhw3AO2zcnRWuI5MueCisfsHqpdypVZIQqTNIFWUFtkTd6znCNRjLX3inL/zTRw4UQ7oIntnGWdNuQAIXDZGE1uawg7MIbGdjXBoH9ySOqVJ32ZJxH03GW/QW0g0dQi4SXcLMEufhUTIZxJ9wChdKJUBUt2uVQ2JJMuT7Zh/kBamiobuNKVupwRNv0Dru2c7MnF6UvU6yotK0LvETPHl0D8=",
      `__VIEWSTATEGENERATOR` = "ABED7CFD",
      `__EVENTVALIDATION` = "xCEbZdF+G5wx54nrTfzZQD0ZVS3tej1sFbNU3/qOQtAidqtZ49KdDT6VQ1CkmySlYZcHI5BaeDQ8oLXAtuuIxzRv8ed4GxSmptfMwDW6FAicKCAlbYD7VEiKx9uBkk52vxTj5pQaAXMearbWZ8SCUh/kQJUfBotgvi1K6hsbp83UvbV9MTmFaQbpnAcbxwlh",
      `ctl00$ContentPlaceHolder1$txtFilter` = letter,  # Insert current letter
      `ctl00$ContentPlaceHolder1$txtPersonID` = ""
    ) |>
    req_perform()
  
  # Parse the response
  page <- resp_body_html(response)
  
  # Extract names using the .myNameTitle class and <strong> tag inside it
  names <- page %>%
    html_nodes(".myNameTitle strong") %>%  # Use the correct selector
    html_text(trim = TRUE)
  
  # Convert the extracted names into a data frame
  names_df <- data.frame(Name = names)
  
  # Append the extracted names to the main data frame
  ada_all_names_df <- rbind(ada_all_names_df, names_df)
  
  # Output message for each iteration
  cat("Names for letter", letter, "have been extracted.\n")
}

# Save all the names to a single CSV file after the loop completes
write.csv(all_names_df, "ada_all_extracted_names.csv", row.names = FALSE)

# Final message
cat("Completed extraction for all letters of the alphabet and saved to ada_all_extracted_names.csv.\n")
