library(limma)
library(jsonlite)

CDEnhancer <- function(eRNA, frac, type)
{
    rec = list()
    for (j in 1:ncol(frac))
    {
        design <- model.matrix(~ type * frac[, j] -1, 
                               data = data.frame(type, frac[, j]))
        colnames(design)[c(2,ncol(design))] = c("cell_type", "interaction")

        Int.o <- lmFit(eRNA, design)

        contrast = makeContrasts(
            summation = type + interaction,
            levels = design)

        fit2 = contrasts.fit(Int.o, contrast)
        fit2 = eBayes(fit2)

        temp = topTable(fit2, coef = "summation", adjust.method = "fdr", number = Inf) 
        temp <- temp[rownames(eRNA), ]

        rec[[j]] = temp
    }

    names(rec) = colnames(frac)
    return(rec)
}

# ==============================
# ✅ NEW: Command-line interface
# ==============================

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
    stop("Need 3 arguments: eRNA.rds frac.rds type.rds")
}

eRNA_path <- args[1]
frac_path <- args[2]
type_path <- args[3]

# Read input files
eRNA <- readRDS(eRNA_path)
frac <- readRDS(frac_path)
type <- readRDS(type_path)

# Run function
rec <- CDEnhancer(eRNA, frac, type)

# Convert each data.frame to list (important for JSON)
rec_json_ready <- lapply(rec, function(df) {
    df[] <- lapply(df, function(x) {
        if (is.factor(x)) as.character(x) else x
    })
    return(df)
})

# Output JSON
cat(toJSON(rec_json_ready, dataframe = "rows", auto_unbox = TRUE))
