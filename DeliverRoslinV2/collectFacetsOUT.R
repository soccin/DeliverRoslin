require(tidyverse)
require(magrittr)

#################################################################
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

tbl <- args %>% 
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
	as.data.frame %>% t
