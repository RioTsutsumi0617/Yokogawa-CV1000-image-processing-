# Set the working directory (optional, change path accordingly)
setwd("***/Image/merge/")   # Replace *** with your directory path

# List all .avi files in the directory
avi_files <- list.files(pattern = "\\.avi$")

# Loop through each file and convert to .mp4 using ffmpeg
for (file in avi_files) {
  # Create output file name by replacing .avi with .mp4
  output_file <- sub("\\.avi$", ".mp4", file)
  
  # Construct the ffmpeg command
  command <- paste("ffmpeg -i", shQuote(file), shQuote(output_file))
  
  # Execute the command
  system(command)
}

# Print completion message
cat("Conversion completed for", length(avi_files), "files.\n")
