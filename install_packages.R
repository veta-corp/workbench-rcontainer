# Read package list and filter out blank lines and comments
pkgs <- scan('/tmp/packages.txt', what='character', sep='\n', quiet=TRUE)
pkgs <- trimws(pkgs)
pkgs <- pkgs[pkgs != '' & !grepl('^#', pkgs)]

# Install each package, logging output to /tmp/<package>.log
for (p in pkgs) {
  log_file <- paste0("/tmp/", p, ".log")
  message("Installing: ", p, " (logging to ", log_file, ")")
  cmd <- sprintf(
    "Rscript -e \"install.packages('%s', Ncpus=4, repos='https://packagemanager.posit.co/cran/latest')\" > %s 2>&1",
    p, log_file
  )
  system(cmd)
}