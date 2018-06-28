suppressPackageStartupMessages(require(tidyverse))
suppressPackageStartupMessages(require(magrittr))

#################################################################
write.tsv=function (dd, filename, row.names = T, col.names = NA, na = "NA",
    append = F)
{
    if (!is.data.frame(dd)) {
        dd <- data.frame(dd, check.names = F)
    }
    if (!row.names) {
        col.names = T
    }
    write.table(dd, file = filename, sep = "\t", quote = FALSE,
        col.names = col.names, row.names = row.names, na = na,
        append = append)
}

#################################################################

readFacetsOutFile <- function(outFile) {
	outdat=readLines(outFile)
	dd <- str_match(outdat[grepl(" =",outdat)],"# (.*) = (.*)") %>%
		as.tibble %>%
		select(2,3) %>%
		mutate(V3=gsub(" ","",V3)) %>%
		distinct %>%
		mutate(V2=gsub(" ","_",V2))

	tumorId=dd %>%
		filter(V2=="tumor_id") %>%
		pull(V3)
	dd$TumorId=tumorId
	return(dd)
}

#################################################################
#################################################################

args=commandArgs(trailing=T)

outFileTmpl=args[1]

tbl <- args[-1] %>%
	map(readFacetsOutFile) %>%
	bind_rows %>%
	spread(V2,V3)

#commonFields=names(which(apply(tbl,2,function(x){len(unique(x))})==1))
#sampleFields=names(which(apply(tbl,2,function(x){len(unique(x))})!=1))

sampleFields=c("TumorId", "dipLogR", "loglik", "Ploidy", "Purity")
commonFields=c("Facets_version", "cval", "dipt", "genome",
				"min.nhet", "ndepth", "purity_cval", "Seed",
				"snp.nbhd", "unmatched")

sampleTbl <- tbl %>% select(sampleFields)

parameterTbl <- tbl %>%
	select(commonFields) %>%
	distinct %>%
	as.data.frame %>%
	t %>%
	as.data.frame %>%
	rownames_to_column %>%
	rename(Parameter=rowname,Setting=V1)

write.tsv(parameterTbl,paste0(outFileTmpl,".parameters.out"),row.names=F)
write.tsv(sampleTbl,paste0(outFileTmpl,".samplesValues.out"),row.names=F)
