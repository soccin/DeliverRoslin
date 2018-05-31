suppressPackageStartupMessages(require(tidyverse))
args=commandArgs(trailing=T)
OFILE=args[1]
args[-1] %>%
    map(read_tsv) %>%
    bind_rows %>%
    write_tsv(OFILE)
