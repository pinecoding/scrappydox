import argparse
import os
import tkinter as tk
from PIL import Image, ImageTk
import yaml as yamlModule
import subprocess
import webbrowser
import markdown
import codecs

# From windows cmd prompt, opened as administrator,
#     assoc .pyw=pythonw
#     ftype pythonw=C:\Users\Sam\ActivePython36\pythonw.exe "%1" %*

# Placing in https://github.com/pinecoding/scrappydox.git repo
# git clone -c core.autocrlf=false -c core.longpaths=true https://github.com/pinecoding/scrappydox.git
# checked in to username "Sam Gabriel", email "pinecoding@gmail.com"

class Person:
    def __init__(self, initialProperties=None, body=None):
        if isinstance(initialProperties, str):
            self.yaml = initialProperties
        elif initialProperties is not None:
            self.properties = initialProperties
        if body is not None:
            self.body = body
    
    @property
    def yaml(self):
        return self.__yaml
        
    @yaml.setter
    def yaml(self, yaml):
        self.__yaml = yaml
        self.__props = yamlModule.load(yaml)

    @property
    def properties(self):
        return self.__props
        
    @properties.setter
    def properties(self, properties):
        self.__props = properties
        self.__yaml = yaml.dump(properties, default_flow_style=False)
        
    def run(self):
        parser = argparse.ArgumentParser(description='Provide info on a person')
        parser.add_argument('-m', '--markdown', dest='markdown', help='generate markdown to stdout', action='store_true')

        self.filename = parser.prog
        self.filenameBase, self.filenameExt = os.path.splitext(self.filename)

        args = parser.parse_args()
        if args.markdown:
            print(self.markdown())
        else:
            self.display()
        
    def markdown(self):
        return f"""\
## {self.__props["Name"]}

{self.fstr(self.body)}
"""

    def html(self):
        return markdown.markdown(self.markdown(), ["extra"])
        
    def display(self):
        root = tk.Tk()

        height=25
        
        if "Photo" in self.__props:
            # photo = tk.PhotoImage(file=self.__props["Photo"])
            image = Image.open(self.__props["Photo"])
            image.thumbnail((280, 360), Image.ANTIALIAS)
            photo = ImageTk.PhotoImage(image)

            text1 = tk.Text(root, height=height, width=35)
            text1.insert(tk.END, '\n')
            text1.image_create(tk.END, image=photo)
            text1.pack(side=tk.LEFT)

        textarea = tk.Frame(root)
        text2 = tk.Text(textarea, height=height, width=50, wrap=tk.WORD)
        scroll = tk.Scrollbar(textarea, command=text2.yview)
        text2.configure(yscrollcommand=scroll.set)
        # text2.tag_configure('bold_italics', font=('Arial', 12, 'bold', 'italic'))
        text2.tag_configure('big', font=('Verdana', 20, 'bold'))
        text2.tag_configure('color', foreground='#476042', font=('Verdana', 12))
        text2.insert(tk.END, self.__props["Name"] + "\n", 'big')
        text2.insert(tk.END, self.fstr(self.body), 'color')

        # text2.tag_bind('follow', '<1>', lambda e, t=text2: t.insert(tk.END, "Not now!"))
        # text2.insert(tk.END, 'follow-up\n', 'follow')

        textarea.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        text2.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scroll.pack(side=tk.RIGHT, fill=tk.Y)
        
        buttons = tk.Frame(root)
        buttons.pack(side=tk.RIGHT, fill=tk.Y)
        
        if "Mother" in self.__props:
            def openMother():
                subprocess.Popen(["pythonw", self.__props["Mother"]])
            mother = tk.Button(buttons, text="Mother", command=openMother)
            mother.pack(anchor="w")

        if "Father" in self.__props:
            def openFather():
                subprocess.Popen(["pythonw", self.__props["Father"]])
                # webbrowser.open_new_tab("test.html") # works
            father = tk.Button(buttons, text="Father", command=openFather)
            father.pack(anchor="w")

        if "Siblings" in self.__props:
            def openSiblings():
                for sibling in self.__props["Siblings"]:
                    subprocess.Popen(["pythonw", sibling["file"]])
            siblings = tk.Button(buttons, text="Siblings", command=openSiblings)
            siblings.pack(anchor="w")

        if "Children" in self.__props:
            def openChildren():
                for child in self.__props["Children"]:
                    subprocess.Popen(["pythonw", child["file"]])
            children = tk.Button(buttons, text="Children", command=openChildren)
            children.pack(anchor="w")

        def genHtml():
            filename = self.filenameBase + ".html"
            file = codecs.open(filename, "w", encoding="utf-8", errors="xmlcharrefreplace")
            file.write(self.html())
            webbrowser.open_new_tab(filename)
        htmlButton = tk.Button(buttons, text="HTML", command=genHtml)
        htmlButton.pack(anchor="w")

        root.mainloop()

    def fstr(self, template):
        p = self.properties
        return eval(f'f"""{template}"""')
