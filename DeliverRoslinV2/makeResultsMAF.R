#
# Analysis | DMP
# set (124) ==> Caller (37)
# ExAC_FILTER (123) ==> exac_filter
# _Need_to_Add_ ==> REDACTION_SOURCE
#

getSDIR <- function(){
    args <- commandArgs(trailing=F)
    TAG <- "--file="
    path_idx <- grep(TAG,args)
    SDIR <- dirname(substr(args[path_idx],nchar(TAG)+1,nchar(args[path_idx])))
    if(length(SDIR)==0) {
        return(getwd())
    } else {
        return(SDIR)
    }
}

getEventTag <- function(xx){
    with(xx,paste(
            Chromosome,
            Start_Position,
            End_Position,
            Reference_Allele,
            Tumor_Seq_Allele2,
            Tumor_Sample_Barcode,
            Matched_Norm_Sample_Barcode,
            sep=":"
        )
    )
}

###########################################################################
###########################################################################

VERSION <- scan(file.path(getSDIR(),"VERSION"),"")[1]
flChromosome <- c(1:22,"X","Y")
dmpMAFCols <- scan(file.path(getSDIR(),"dmpMAFColumns"),"")


args <- commandArgs(trailing=T)

if(len(args) != 3) {
    cat("\n   usage: makeResultsMAF.R PORTAL.maf ANALYSIS.maf OUTPUT.maf\n\n")
    quit()
}

portalMafFile <- args[1]
analysisMafFile <- args[2]
outputMafFile <- args[3]

suppressPackageStartupMessages(require(tidyverse))

portalMaf <- read_tsv(portalMafFile,comment="#",col_types=cols(Chromosome=col_character()))
portalMaf$TAG <- getEventTag(portalMaf)

header <-
    readLines(analysisMafFile,50) %>%
    as.tibble %>%
    filter(grepl("^#",value)) %>%
    pull(value)
versionHdr <- grep("# Version",header)
header[versionHdr] <- paste0(header[versionHdr],", ",VERSION)

analysisMaf <- read_tsv(analysisMafFile,comment="#",col_types=cols(Chromosome=col_character()))
analysisMaf$TAG <- getEventTag(analysisMaf)
analysisMaf <- analysisMaf %>%
    filter(TAG %in% portalMaf$TAG) %>%
    select(-TAG) %>%
    filter(!Chromosome %in% c("MT","M")) %>%
    arrange(Tumor_Sample_Barcode) %>%
    arrange(Start_Position) %>%
    arrange(factor(Chromosome,flChromosome)) %>%
    mutate(REDACTION_SOURCE=NA) %>%
    mutate(t_var_freq=round(t_alt_count/t_depth,3)) %>%
    mutate(n_var_freq=round(n_alt_count/n_depth,3)) %>%
    select(dmpMAFCols)

write(header,outputMafFile)
write_tsv(analysisMaf,outputMafFile,col_names=T,append=T,na="")

