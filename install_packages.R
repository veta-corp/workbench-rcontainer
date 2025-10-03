pkgs <- scan("/tmp/packages.txt", what="character")

for (p in pkgs) {
  log_file <- paste0("/tmp/", p, ".log")
  message("Installing: ", p, " (logging to ", log_file, ")")
  cmd <- sprintf(
    "Rscript -e \"install.packages('%s', Ncpus=4, repos='https://packagemanager.posit.co/cran/latest')\" > %s 2>&1",
    p, log_file
  )
  system(cmd)
}