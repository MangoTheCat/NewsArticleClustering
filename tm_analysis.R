#
# Hierarchical Document Clustering using tm and dendextend 
# 
# Author: Mango-Solutions

# Setup
library(tm)
library(jsonlite)
library(proxy)   ## hierarchical clustering, provides cosine distance
library(dendextend)

source("processing_utils.R")

# Source Data 
#################################

gaudian_feed = "http://www.theguardian.com/uk-news/rss"
bbc_feed = "http://feeds.bbci.co.uk/news/uk/rss.xml"
independent_feed = "http://www.independent.co.uk/news/uk/rss" 

fetch_articles(gaudian_feed, 'latest_data/guadian.json')
fetch_articles(bbc_feed, 'latest_data/bbc.json')
fetch_articles(independent_feed, 'latest_data/independent.json')
  

# RUN ANALYSIS
#################################

# Load and Preprocess
bbc_articles <- load_and_preprocess_articles("latest_data/bbc.json", source_label = 'BBC')
guadian_articles <- load_and_preprocess_articles("latest_data/guadian.json", source_label = 'Guadian')
independent_articles <- load_and_preprocess_articles("latest_data/independent.json", source_label = 'Independent')

# Extract metadata for labeling dendogram
bbc_labels = sapply(bbc_articles, FUN=function(x) meta(x)$heading )
df_bbc = data.frame(heading=bbc_labels, colour="royalblue1", source="bbc", stringsAsFactors = FALSE)

guadian_labels = sapply(guadian_articles, FUN=function(x) meta(x)$heading )
df_guadian = data.frame(heading=guadian_labels, colour="darkgreen", source="guadian", stringsAsFactors = FALSE)

independent_labels = sapply(independent_articles, FUN=function(x) meta(x)$heading )
df_independent = data.frame(heading=independent_labels, colour="purple1", source="independent", stringsAsFactors = FALSE)

# Combine all articles into one corpus
df_all = rbind(df_bbc, df_guadian, df_independent)
articles_corpus = c(bbc_articles, guadian_articles, independent_articles)
ids = row.names(df_all)
for (idx in seq_along(articles_corpus)) {
  meta(articles_corpus[[idx]], "id") <- ids[[idx]]
}

# Calculate TF-IDF Scores
acticles_dtm <- DocumentTermMatrix(articles_corpus, control = list(weighting = weightTfIdf))

# Trim matrix of sparse terms
acticles_dtm <- removeSparseTerms(acticles_dtm, sparse=0.90)
doc_m <- as.matrix(acticles_dtm)

# Create distance matrix, cluster and dendogram
d <- dist(doc_m, method="cosine")
hc <- hclust(d, method="ward.D2")
dend <- as.dendrogram(hc)

# Get ids of articles
dend_labels <- labels(dend)
dend_cols <- sapply(dend_labels, FUN=function(x) df_all[x, "colour"] )
dend_headings <- sapply(dend_labels, FUN=function(x) df_all[x, "heading"] )

# Set colour and article titiles
labels_colors(dend) <- dend_cols
labels(dend) <- dend_headings

# Plot whole dendogram
plot_dend(dend, k=10, labels=FALSE)

# Plot partial dendogram with labels 
plot_dend(dend[[2]][[2]][[2]][[2]][[2]], k=2, horiz=TRUE)


