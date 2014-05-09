import cloudant
import os
import re

# CLOUDANT = {
#     "USERNAME": os.environ.get('CLOUDANT_USERNAME'),
#     "KEY": os.environ.get('CLOUDANT_KEY'),
#     "SECRET": os.environ.get('CLOUDANT_SECRET'),
#     "DATABASE": os.environ.get('CLOUDANT_DATABASE')
# }

# account = cloudant.Account(CLOUDANT['USERNAME'])
# account.login(CLOUDANT['KEY'], CLOUDANT['SECRET']).raise_for_status()
# db = account.database(CLOUDANT['DATABASE'])
# code_sample_regex = re.compile('```(?P<language>\\w+)\n(?P<path>.*)\n```')

# get all code samples from the db
# format into object for fast access

# walk docs tree in `/docs`
# replace sample IDs with actual code
# write result to `/source`
docs = os.walk('docs')
print docs
