""" Script to fetch news articles from RSS feeds and store text and meta data as a JSON file.

@author: Chris Musselle
"""
# Standard libs
import os 
import sys
import json

# 3rd Party libs 
import requests
import bs4
import feedparser


def get_articles(feed_url, json_filename='articles.json'):
    """ Update a JSON file to hold article links, published data and text data """

    feed = feedparser.parse(feed_url)
    
    # Read in articles already downloaded if they exist
    if os.path.exists(json_filename):
        JSON_articles = json.load(open(json_filename, 'r'))
    else:
        JSON_articles = {}
        
    article_counter = 0

    for item in feed['items']:
        
        # Use title of the article as an id
        title = item['title']
        
        # Only process article if we have not done so already
        if title not in JSON_articles:
        
            # Store basic info from feed
            article_url = item['link']
            article_published_date = item['published']
            JSON_articles[title] = {'url': article_url, 
                                    'published_date': article_published_date}
                
            # Get full web content for link
            r = requests.get(article_url)

            # Parse HTML using BeautifulSoup
            soup = bs4.BeautifulSoup(r.content, 'lxml')

            # Find all the p tags 
            p_tags = soup.find_all(name='p')

            # Extract just the text from the p tags
            p_tags_text = [p.text for p in p_tags]

            # Join all p tag strings by a newline
            all_text = '\n'.join(p_tags_text)

            # Store and increment counter 
            JSON_articles[title]['text'] = all_text
            article_counter += 1 

    # Write updated file.
    with open(json_filename, 'w', encoding='utf-8') as json_file: 
        json.dump(JSON_articles, json_file, indent=4)

    print('Added {} new articles'.format(article_counter))


if __name__ == '__main__':

    # Pass Arguments 
    args = sys.argv[1:]
    feed_url = args[0]
    filepath = args[1]

    # Create the directory if it does not already exist
    dirname = os.path.dirname(filepath)
    if dirname:
        if not os.path.exists(dirname):
            os.makedirs(dirname)

    # Get the latest articles and append to the JSON file given
    print('Fetching articles for {}'.format(feed_url))
    get_articles(feed_url, filepath)
    print('Saving to {}'.format(filepath))

