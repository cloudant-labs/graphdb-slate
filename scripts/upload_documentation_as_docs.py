#!/usr/bin/python

from bs4 import BeautifulSoup, NavigableString
import cloudant
import os
import sys

import logging

logging.basicConfig(level=logging.DEBUG)

USERNAME = 'docs-testb'
KEY = os.environ.get('USERNAME')
SECRET = os.environ.get('PASSWORD')
DATABASE = sys.argv[1]
HEADINGS = ['h1', 'h2', 'h3']

print KEY
print SECRET
print "database" + DATABASE

if KEY and SECRET:
    print "account with auth"
    account = cloudant.Account(USERNAME, auth=(KEY, SECRET))
else:
    print "account without auth"
    account = cloudant.Account()

database = account.database(DATABASE)

def make_docs(headers, filename):
    print "make_docs called with filename = " + filename
    docs = dict()
    for header in headers:
        if not 'id' in header.attrs:
            print 'header does not have an id attribute'
            continue;
        doc = dict(_id=filename + '-' + header['id'], title=header.get_text())
        children = []
        for sibling in header.next_siblings:
            if sibling.name and sibling.name in HEADINGS:
                break
            elif sibling.string and not sibling.string == '\n':
                children.append(sibling.string)
            elif type(sibling) is NavigableString:
                children.append(unicode(sibling))
            else:
                for s in sibling.strings:
                    children.append(s)
        doc['text'] = ' '.join(children)
        if doc['text']:
            docs[doc['_id']] = doc
    return docs

def index_file(filename):
		with open('build/' + filename + '.html', 'r') as f:
				html = f.read()
				soup = BeautifulSoup(html)
				docs = dict()
				for heading in HEADINGS:
					  headers = soup.find_all(heading)
					  docs.update(make_docs(headers, filename))
				alldocs = database.all_docs().post(params=dict(keys=docs.keys()))
				alldocs.raise_for_status()
				for row in alldocs.json()['rows']:
					  if 'id' not in row:
					      continue
					  _id = row['id']
					  rev = row['value']['rev']
					  docs[_id]['_rev'] = rev
				response = database.bulk_docs(*docs.values())
				response.raise_for_status()
				
for filename in ["index","api", "guides", "libraries", "basics"]:
		index_file(filename)
