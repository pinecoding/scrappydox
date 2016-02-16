NAME
    scrappydox - Preprocessor for building documents from markdown files

SYNOPSIS
    scrappydox [ROOT FILE] [OTHER FILES]...

DESCRIPTION
    Scrappydox builds a markdown document out of multiple markdown files,
    starting from [ROOT FILE] as the main, top-level, section.

    [OTHER FILES] are handled in two different ways:

    -   If a filename does not contain caret path-separator characters, then
        it is added as a subsection of [ROOT FILE], in the order
        encountered.

    -   If a filename contains caret path-separator characters, then
        scrappydox will attempt to match its path to other paths to find its
        appropriate place in the hierarchy of sections in the document.

    As an example of path matching, consider the following list of files
    passed to scrappydox:

        Mission_Trails.txt Geology.txt Botany.txt Botany^Plant_Communities.txt Botany^Plant_List.txt

    Scrappydox will match paths to create a document with the following
    section hierarchy:

        Mission Trails
            Geology
            Botany
                Plant Communities
                Plant List

    Section headers and the overall title are taken from the filename (minus
    the path), or, if present, from the first line of the file, if it is a
    Markdown header line. Scrappydox assumes Markdown atx-style headers
    without closing hash characters. Scrappydox adjusts headers as
    appropriate to the nesting level within the overall document being
    created.

    Optional head and tail components can be added to filenames to enforce
    sorting or provide extra information. Both are stripped away and
    ignored. Everything before and including the last plus-sign character,
    and everything after and including the first tilde character, are
    ignored. Here is an example of a filename with both a head and tail:

        01+Geology~Mission_Trails.txt

    An HTML comment block at the top of the docment, or after the title line
    (first line) can be used to specify commands for loading additional
    files, and for the definition of user variables used for sorting and
    filtering of the files loaded. Following is an example of a root
    document specifying the remainder of the document, so that [OTHER FILES]
    are not needed:

        # Mission Trails
        <!--
        * Choose: Field eq Botany
        * Choose: Field eq Geology
        * Choose: Field eq Zoology
        * Exclude: Field eq Anthropology
        * Child: Announcements.txt
        * Load: Announcements^*.txt
        * Child: Stories.txt
            - Title: Trail Tails
        * Load: ../_Stories/Stories^*.txt
            - Sort: ascending alpha using field
            - Sort: ascending alpha on name
        * Child: Glossary.txt
        * Load from Refs: path Glossary using ../_Glossary/Glossary^*.txt
        * Child: References.txt
        * Load from Refs: no path using ../_References/References^*.txt
        + Author: Sam Gabriel
        -->

        **Authored By:** <+Author+>  
        **Document Date:** <*Date*>

    The HTML comment begin and end indicators must be flush left, and each
    on its own line, as shown. Commands are prefixed by asterisk bullets,
    user-defined properties are prefixed by plus-sign bullets.

    Each "Child" command loads a file as a child section, or files as child
    sections (if wildcards are used). Each "Load" command loads files for
    path matching, where each file must have a path that matches a filename
    in the document in order to be included as a subsection under the
    matched filename.

    "Child" and "Load" commands can include a title modifier as a subbullet
    that begins with a dash. This is generally applied to a "Child" command
    for a single file, to change the title of the resulting child section.
    That way a file can be reused as-is in multiple documents, where the
    section title must be appropriate for the containing document.

    "Child" and "Load" commands can include sort modifiers as subbullets.
    Two are in the example above:

            - Sort: ascending alpha using field
            - Sort: ascending alpha on name

    The first (primary) sort line sorts ascending alphabetically using the
    user-defined property called "field". The second (secondary) sort line
    sorts ascending (descending is the alternate option) alphabetically
    (numeric is the alternate option to alpha) on the system-defined
    (built-in) value "name", which is the filename without the path ("title"
    is another system-defined value).

    Sort can be a command on its own, in which case it applies to the
    children of the file, after the document tree has been constructed in
    memory. The "Reference.txt" file sorts its children by name:

        #
        <!--
        * Sort: ascending alpha on name
        -->

    This file also illustrates the use of a blank line beginning with the
    Markdown header indicator (number sign), to indicate that the
    system-defined "name" field should be used for the section title (with
    underscores replaced by spaces, as necessary). In this case, the section
    title will be "References".

    The header for one of the "Stories" files illustrates how the
    user-defined property "Field" is defined:

        # 
        <!--
        + Field: Geology
        -->

    The "Choose" and "Exclude" commands operate on user-defined properties.
    "Choose" only loads a file if the property it references ("field" in
    this case) is not defined for the file, or the logical statement
    referencing the property is true for some setting of the property in the
    file (each property can have multiple settings). "Exclude" causes a file
    to not be loaded if the property it references is defined for the file,
    and the logical statement referencing the property is true for some
    setting of the property in the file. Logical statements use Perl's
    string and numeric operators.

    There are two forms of the "Load from Refs" command, and both are
    illustrated in the example above.

        * Load from Refs: path Glossary using ../_Glossary/Glossary^*.txt
        * Load from Refs: no path using ../_References/References^*.txt

    The first matches the specified path ("Glossary" in this case) to the
    path in each shorthand link statement encountered (see below for a
    description of shorthand link statements), and if it finds a match, it
    tries to load a file using the filename specification at the end of the
    statement. The filename specification must contain a asterisk character:
    the asterisk is replaced by the name (non-path part) of the link.
    Following is an example of a link with a path:

        <#Glossary^Bajada#>

    In the example above, this link maps to the following filename:

        ../_Glossary/Glossary^Bajada.txt

    The second form is the same as the first, except that it is for links
    that do not have a path. For example, the following link to a reference
    has no path:

        <#Leitner 2011 SDCNP#>

    In the example above, this link maps to the following filename:

        ../_References/References^Leitner_2011_SDCNP.txt

    Refs can also be loaded from anchor blocks within a file. For example, a
    file Glossary~Complete.txt might contain anchor blocks for glossary
    entries like the following:

        <'Glossary^-A-'>
        **<"Glossary^Alluvial Fan">** "is a fan- or cone-shaped deposit
        of sediment crossed and built up by streams" 
        (<http://www.wikipedia.org/wiki/Bajada_(geography)>).

        <'Glossary^-B-'>
        **<"Glossary^Bajada">** "consists of a series of coalescing
        <#Glossary^alluvial fan#>s along a mountain front" 
        (<http://www.wikipedia.org/wiki/Alluvial_fan>).

    An anchor block starts with a line containing a visible anchor. In the
    example above, the first visible anchor is:

        <"Glossary^Alluvial Fan">

    The anchor block ends before the next line containing a visible or
    invisible anchor. In the example above, the first anchor block ends
    before the line with the following invisible anchor:

        <'Glossary^-B-'>

    To make anchor blocks available for "Load from Refs" commands, the file
    containing them must appear in a "Split for Refs" command. The command
    for the Glossary~Complete.txt file, along with an appropriate "Load from
    Refs" command, is:

        * Split for Refs: Glossary~Complete.txt using Glossary^*
        * Load from Refs: path Glossary using Glossary^*

    Each anchor is turned into a filename by taking the name portion of the
    anchor (ignoring the path) and substituting it for the asterisk in the
    filename specification at the end of the statement. These generated
    filenames can then be matched by the generated filenames in "Load from
    Refs" statements. If a match is found, the anchor block is fit into the
    hierarchy of sections based on the path in its generated filename.

    In addition to document construction capabilities, scrappydox supports
    the following shorthand notations:

    <@filename@>        Inserts the contents of file "filename" after
                        parsing it for other shorthand notations. Useful for
                        template text containing variable references.

    <"name">            Defines an HTML anchor with ID and title both set to
                        "name".

    <"^name">           Defines an HTML anchor with title "name" and ID set
                        to the full path of the current file within the
                        document, with "^name" appended.

    <"prefix+name">     Defines an HTML anchor title set to "name" and ID
                        set to "prefix+name". "prefix+" provides a namespace
                        independent of the path hierarchy, as the path
                        hierarchy does not contain plus signs.

    <'anchor'>          Same as the double-quote HTML anchor notations
                        above, except that no title is displayed.

    <#link#>            Defines a link to any of the anchor-types defined
                        above. The link will be the same as the anchor it
                        links to, and follows the same rules for what will
                        be displayed as the title of the link.

    <*property*>        Is replaced by the named system-defined property.
                        "Date" and "Name" are the only system-defined
                        properties currently supported. "Name" is the
                        portion of the filename after the caret-separated
                        the path.

    <+property+>        Is replaced by the named user-defined property.

    <{r}text{r}>        Colors the enclosed text red.

    <{g}text{g}>        Colors the enclosed text green.

    <{b}text{b}>        Colors the enclosed text blue.

    <{P}text{P}>        Sets the background of the enclosed text to pink.

    <{Y}text{Y}>        Sets the background of the enclosed text to yellow.

    <{B}text{B}>        Sets the background of the enclosed text to blue.

    <{-}text{-}>        Sets the enclosed text to strikethrough font.

    Shorthand translation can be turned off for a file by setting the system
    property "process shorthand" to "0" in that file:

        <!--
        * Process Shorthand: 0
        -->

CAVEATS
    The "Load from Refs" command works best when the file system is case
    insensitive as it is by default on Windows and Mac OS X. Otherwise, the
    refs will have to match case with the filename for the file to load; not
    great for glossary entries where the case of the ref should match the
    context of the ref.

    To make "Load from Refs" work for all characters, characters in refs
    that are not allowed in filenames ('\', '/', ':', '*', '?', '"', '<',
    '>', '|') are URL-encoded; e.g. ':' becomes '%3a'. This means that the
    filenames must contain the URL-encoded characters. Filenames are
    URL-decoded before they are used to create user-display information,
    such as titles.

    Both the need for a case insensitive operating system and the need to
    URL-encode special characters in filenames can be avoided by using the
    "Split for Refs" command to make reference targets available from anchor
    blocks within a file.

LICENSE
    Copyright (c) 2015 Sam Gabriel

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

