# configure deployment

## add secure entries for username and password in .travis.yml, e.g.

```
env:
  global:
  - secure: CekvzarBrARhWE2/K1cof7SCnXBSzN/MijwO4hI+n1fITgk18gBEzlfyzd4BD68JZ2fVhPuWIqs+9WxBm+XLZUGYcgiBRovqN9JooElXgyV/CvqIEbJ7Xa4Vw/8mE2qJ1Ce54A8Sdkt4cfOZppyedUg/krzYw5uar3sDWWTt6z0=
  - secure: aSi+sIpBoS6VofHVUToRpvXrHG3avvdwG0frOBh+A8ijsjn3fOACeJm+ipQystYtCciZ09l5A/Q/Tkd1sogWy8ymU7bULVJsJb+aNJRM+00QYFelCLpxD8c6gP7aty/IRk7RfWqrii1ZHQ6KSeSqlJf6P6gYZOOA+1IQBO532vY=
```

## add people to notify for build success in .travis.yml

```
notifications:
  email:
    - adrian.warman@uk.ibm.com
    - kim@cloudant.com
  on_success: always
```


## set variables in deployment scripts

 * set the username in deploy-remote.sh
 
 * set username in upload_documentation_as_docs.py
 
 * follow instructions in build scripts


# add content


# add navigation



