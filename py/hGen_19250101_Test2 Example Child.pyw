import person
id = "hGen_19250101_Test2"
this = person.Person(f"""\
ID: {id}
Name: Example Child
Date of Birth: 1 January 1925
Location of Birth: Berkeley, CA
Date of Death: 01 January 2010
Location of Death: Portland, OR
""",
"""\
Born {p["Date of Birth"]}, {p["Location of Birth"]}. Died {p["Date of Death"]}, {p["Location of Death"]}.
""")
if __name__ == '__main__':
    this.run()
