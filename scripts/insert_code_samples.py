import cloudant
import os
import re

CLOUDANT = {
    "USERNAME": os.environ.get('CLOUDANT_USERNAME'),
    "KEY": os.environ.get('CLOUDANT_KEY'),
    "SECRET": os.environ.get('CLOUDANT_SECRET'),
    "DATABASE": os.environ.get('CLOUDANT_DATABASE')
}

if CLOUDANT.get('USERNAME'):
    account = cloudant.Account(CLOUDANT['USERNAME'])
    account.login(CLOUDANT['KEY'], CLOUDANT['SECRET']).raise_for_status()
    db = account.database(CLOUDANT['DATABASE'])
else:
    account = cloudant.Account()
    db = account.database('slate-code')

code_sample_regex = re.compile('```(?P<language>\\w+)\n(?P<path>.*)\n```')
code_sample_string = '```{language}\n{path}\n```'

# get all code samples from the db
# format into object for fast access
sample_code = dict()
for doc in db.all_docs().iter(params=dict(include_docs=True)):
    if 'text' in doc['doc']:
        sample_code[doc['id']] = doc['doc']['text']

# walk docs tree in `/docs`
# replace sample IDs with actual code
# write result to `/source`
docs = os.walk('docs')
for doc in docs:
    dirname = doc[0]
    filenames = doc[2]
    for filename in filenames:
        path = os.path.join(dirname, filename)
        with open(path) as f:
            contents = f.read()
            for match in re.finditer(code_sample_regex, contents):
                args = match.groupdict()
                current_sample = code_sample_string.format(**args)
                sample_id = '/'.join([args['path'], args['language']])
                new_sample = sample_code.get(sample_id)
                if not new_sample:
                    print sample_id, 'missing'
                else:
                    contents = contents.replace(current_sample, new_sample)
        dest_path = path.replace('docs', 'source')
        with open(dest_path, 'w') as f:
            f.write(contents)
