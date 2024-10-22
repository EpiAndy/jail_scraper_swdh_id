library(pdftools)
library(dplyr)

# Update this file path to where you saved the PDF on your local system
pdf_file_path <- "https://owyheecounty.net/wp-content/uploads/2024/10/JailRoster-8.pdf"

# Load the PDF text
pdf_text <- pdf_text(pdf_file_path) %>%
  strsplit(split = "\n") %>%
  unlist()

# Extract names based on patterns (assuming names are in uppercase with a comma between last and first name)
# Regex captures both last and first names and ignores any following booking number or data
names <- pdf_text[grepl("^[A-Z]+, [A-Z ]+", pdf_text)]

# Remove everything after the full name (i.e., after the first space or number after the name)
# This regex stops after the first part of the booking number or release data
cleaned_names <- sub("(, [A-Z ]+)(\\s+\\d.*|\\s+\\*.*)", "\\1", names)

# Create a data frame with the cleaned names and additional information
inmate_data <- data.frame(
  name = as.character(cleaned_names),
  facility = "Owyhee County Jail",
  jurisdiction = "Owyhee County",
  program = "Scrape Owyhee"
) %>%
  distinct() %>%
  mutate(date = Sys.Date())

# Save the result to a CSV file
write.csv(inmate_data, "Owyhee_Inmate_Names.csv", row.names = FALSE)

# Final message
cat("Data saved to Owyhee_Inmate_Names.csv.\n")
