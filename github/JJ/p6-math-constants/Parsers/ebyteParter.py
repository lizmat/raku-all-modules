#!/usr/bin/env python3

from urllib.request import urlopen
from bs4 import BeautifulSoup

url = "http://www.ebyte.it/library/educards/constants/ConstantsOfPhysicsAndMath.html"
soup = BeautifulSoup(urlopen(url).read(), "html5lib")
f = open("ebyteParse-output.txt", "w")

table = soup.find("table", attrs={"class": "grid9"})

rows = table.findAll("tr")
for tr in rows:
    # If its a category of constants we write that as a comment
    if tr.has_attr("bgcolor"):
        f.write("\n\n# " + tr.find(text=True) + "\n")
        continue

    cols = tr.findAll("td")
    if (len(cols) >= 2):
        if (cols[0]["class"][0] == "box" or cols[0]["class"][0] == "boxi" and cols[1]["class"][0] == "boxa"):
            constant = str(cols[0].find(text=True)).replace(" ", "-")
            value = str(cols[1].find(text=True))
            value = value.replace(" ", "").replace("...", "").replace("[", "").replace("]", "")
            print(constant + "\t" + value)
            f.write(constant + "\t" + value)

    f.write("\n")

f.close()
