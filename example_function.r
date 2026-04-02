library(limma)
CDEnhancer <- function(eRNA, frac, type)
{
        rec = list()
        for (j in 1:ncol(frac))
        {
                # Create design matrix for Condition, CellType, and their interaction
                design <- model.matrix(~ type * frac[, j] -1, 
                                       data = data.frame(type, frac[, j]))
                colnames(design)[c(2,ncol(design))] = c("cell_type", "interaction")
                # Fit the limma model using the design matrix for CellType1
                Int.o <- lmFit(eRNA, design)
                
                # define the contrast for sum of 2 coef (one for condition, one for interaction)
                contrast = makeContrasts(
                        summation = type + interaction,
                        levels = design)
                
                fit2 = contrasts.fit(Int.o, contrast)
                # Apply empirical Bayes moderation
                fit2 = eBayes(fit2)
                
                temp = topTable(fit2, coef = "summation", adjust.method = "fdr", number = Inf) 
                temp <- temp[rownames(eRNA), ]  # Reorder rows of temp to match eRNA
                
                rec[[j]] = temp
        }
        
        names(rec) = colnames(frac)
        
        return(rec)
}