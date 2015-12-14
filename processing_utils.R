
# Setup
library(tm)
library(jsonlite)
library(proxy)   ## hierarchical clustering, provides cosine distance
library(dendextend)

#' fetch_articles
#'
#' Call the Python process to fetch the latest articles from an RSS feed.
#'
#' @param url RSS feed url for the selected news website
#' @param filepath The path and filename to where the articles are saved. 
#' If the file already exists, only new articles not already present will be 
#' saved to the file.
#'
#' @return Messages from stdout are printed to the console 
#' @export
fetch_articles <- function(url, filepath) {
  
  command = "python"
  path2script='"fetch_RSS_feed.py"'
  
  args = c(url, filepath)
  allArgs = c(path2script, args)
  
  output = system2(command, args=allArgs, stdout=TRUE)
  print(output)
}


#' load_json_file
#'
#' Load the raw data into a VCorpus object.
#'
#' @param filepath Path to JSON file contining the raw data.
#'
#' @return A list of articles returned as a VCorpus object. 
#' @export
load_json_file <- function(filepath) {
  
  # Load data from JSON
  json_file <- file(filepath, "rb", encoding = "UTF-8")
  json_obj <- fromJSON(json_file)
  close(json_file)
  
  # Convert to VCorpus
  bbc_texts <- lapply(json_obj, FUN = function(x) x$text )
  df = as.data.frame(bbc_texts)
  df = t(df)
  articles = VCorpus(DataframeSource(df))
  articles
}

#' update_metadata
#'
#' Extract meta data from the original raw files and use it to update the given VCorpus articles.
#' 
#' This additional step is necessary at current, due to an issue with the tolower function in the 
#' text preprocessing steps in the tm package. The output may not be a normal VCorpus object and as 
#' a result, the meta data is dropped. this functer therfore added the necessary data back in once 
#' processing is complete. More details at http://stackoverflow.com/questions/24191728/documenttermmatrix-error-on-corpus-argument
#' 
#' @param A VCorpus of articles for which to update thier meta data. 
#' @param filepath Path to JSON file contining the raw data.
#' @param source_label A tag to identify the source of the data.
#'
#' @return A list of articles as a VCorpus object
#' @export
update_metadata <- function(articles, filepath, source_label) {
  
  # Load data from JSON
  json_file <- file(filepath, "rb", encoding = "UTF-8")
  json_obj <- fromJSON(json_file)
  close(json_file)
  
  # Add Meta data from json 
  headings <- names(json_obj)
  date_published <- lapply(json_obj, FUN = function(x) x$published_date)
  urls <- lapply(json_obj, FUN = function(x) x$url)
  
  for (idx in seq_along(articles)) {
    meta(articles[[idx]], "heading") <- headings[[idx]]
    meta(articles[[idx]], "date_published") <- date_published[[idx]]
    meta(articles[[idx]], "url") <- urls[[idx]]
    meta(articles[[idx]], "source_idx") <- idx
    meta(articles[[idx]], "source") <- source_label
  }
  articles
  
}

#' load_and_preprocess_articles
#'
#'  This is a helper to load data, run the preprocessing steps, and update meta data.
#'  
#' @param json_filepath Path to JSON file contining the raw data.
#' @param source_label A tag to identify the source of the data.
#'
#' @return A list of articles as a VCorpus object
#' @export
load_and_preprocess_articles <- function(json_filepath, source_label) {
  
  # Load data 
  articles <- load_json_file(json_filepath)
  
  # Preprocess
  articles <- tm_map(articles, removePunctuation)
  articles <- tm_map(articles, stripWhitespace)
  articles <- tm_map(articles, tolower)
  articles <- tm_map(articles, stemDocument)
  articles <- tm_map(articles, removeWords, stopwords("english"))
  articles <- tm_map(articles, PlainTextDocument)
  
  # Load Metadata again because of 
  # http://stackoverflow.com/questions/24191728/documenttermmatrix-error-on-corpus-argument
  articles <- update_metadata(articles, json_filepath, source_label)
  
  articles
}


#' plot_dend
#'
#' @param dend The dendogram object to plot
#' @param k The value of k passed to "branches_k_color" 
#' @param labels Whether to keep the lables 
#' @param horiz whetehr to plot the reseulting dendogram horizontally
#'
#' @export
plot_dend <- function(dend, k=5, labels=TRUE, horiz=FALSE) {
  
  if (labels == FALSE) {
    labels(dend) <- NA
  } 
  
  if (horiz == TRUE) {
    par(mar = c(4, 2, 0, 35))
  }
  
  dend %>% set("leaves_pch", 19) %>% 
    set("leaves_cex", 1) %>% 
    set("leaves_col", dend_cols) %>%
    set("branches_k_color", k = k) %>%
    plot(horiz=horiz)
}
