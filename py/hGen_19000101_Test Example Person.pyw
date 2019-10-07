import person
id = "hGen_19000101_Test"
this = person.Person(f"""\
ID: {id}
Name: Example Person
Date of Birth: 1 January 1900
Location of Birth: Berkeley, CA
Date of Death: 01 January 1995
Location of Death: Los Angeles, CA
Children:
-   type: daughter
    file: hGen_19250101_Test2
""",
"""\
Born {p["Date of Birth"]}, {p["Location of Birth"]}. Died {p["Date of Death"]}, {p["Location of Death"]}.
""")
if __name__ == '__main__':
    this.run()
