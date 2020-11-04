# example merge data frames based on id with nearest timestamp
# solutions taken from stack overflow:
# https://stackoverflow.com/questions/28072542/merge-nearest-date-and-related-variables-from-a-another-dataframe-by-group
set.seed(42)
df1 <- data.frame(ID=sample(1:3, 10, rep=T),
                  dateTarget=(strptime((paste(
                    sprintf("%02d", sample(1:30,10, rep=T)),
                    sprintf("%02d", sample(1:12,10, rep=T)),
                    (sprintf("%02d", sample(2013:2015,10, rep=T))), sep="")),"%d%m%Y")),
                  Value=sample(15:100, 10, rep=T))
df2 <- data.frame(ID=sample(1:3, 10, rep=T), 
                  dateTarget=(strptime((paste(
                    sprintf("%02d", sample(1:30,20, rep=T)),
                    sprintf("%02d", sample(1:12,20, rep=T)),
                    (sprintf("%02d", sample(2013:2015,20, rep=T))), sep="")),"%d%m%Y")), 
                  ValueMatch=sample(15:100, 20, rep=T))

# --- solution 2: base::lapply() ----

z <- lapply(intersect(df1$ID,df2$ID),function(id) {
  d1 <- subset(df1,ID==id)
  d2 <- subset(df2,ID==id)
  d1$indices <- sapply(d1$dateTarget,function(d) which.min(abs(d2$dateTarget - d)))
  d2$indices <- 1:nrow(d2)
  merge(d1,d2,by=c('ID','indices'))
})

z2 <- do.call(rbind,z)
z2$indices <- NULL

print(z2)


# --- solution 2: data.tables ----


library(data.table)
setDT(df1)
setDT(df2)

setkey(df2, ID, dateTarget)[, dateMatch:=dateTarget]
df2[df1, roll='nearest']

