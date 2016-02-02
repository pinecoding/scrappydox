#!/usr/bin/perl

=pod

=head1 NAME

scrappydox - Preprocessor for building documents from markdown files

=head1 SYNOPSIS

scrappydox [ROOT FILE] [OTHER FILES]...
  
=head1 DESCRIPTION

Scrappydox builds a markdown document out of multiple markdown files, starting from [ROOT FILE] as the main, top-level, section.

[OTHER FILES] are handled in two different ways:

=over 4

=item -

If a filename does not contain caret path-separator characters, then it is added as a subsection of [ROOT FILE], in the order encountered.

=item -

If a filename contains caret path-separator characters, then scrappydox will attempt to match its path to other paths to find its appropriate place in the hierarchy of sections in the document.

=back

As an example of path matching, consider the following list of files passed to scrappydox:

    Mission_Trails.txt Geology.txt Botany.txt Botany^Plant_Communities.txt Botany^Plant_List.txt
    
Scrappydox will match paths to create a document with the following section hierarchy:

    Mission Trails
        Geology
        Botany
            Plant Communities
            Plant List

Section headers and the overall title are taken from the filename (minus the path), or, if present, from the first line of the file, if it is a Markdown header line. Scrappydox assumes Markdown atx-style headers without closing hash characters. Scrappydox adjusts headers as appropriate to the nesting level within the overall document being created.

Optional head and tail components can be added to filenames to enforce sorting or provide extra information. Both are stripped away and ignored. Everything before and including the last plus-sign character, and everything after and including the first tilde character, are ignored. Here is an example of a filename with both a head and tail:

    01+Geology~Mission_Trails.txt

An HTML comment block at the top of the docment, or after the title line (first line) can be used to specify commands for loading additional files, and for the definition of user variables used for sorting and filtering of the files loaded. Following is an example of a root document specifying the remainder of the document, so that [OTHER FILES] are not needed:

    # Mission Trails
    <!--
    * Choose: Field eq Botany
    * Choose: Field eq Geology
    * Choose: Field eq Zoology
    * Exclude: Field eq Anthropology
    * Child: Announcements.txt
    * Load: Announcements^*.txt
    * Child: Stories.txt
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
    
The HTML comment begin and end indicators must be flush left, and each on its own line, as shown. Commands are prefixed by asterisk bullets, user-defined properties are prefixed by plus-sign bullets.

Each "Child" command loads a file as a child section, or files as child sections (if wildcards are used). Each "Load" command loads files for path matching, where each file must have a path that matches a filename in the document in order to be included as a subsection under the matched filename.

"Child" and "Load" commands can include sort modifiers as subbullets that begin with dashes. Two are in the example above:

        - Sort: ascending alpha using field
        - Sort: ascending alpha on name

The first (primary) sort line sorts ascending alphabetically using the user-defined property called "field". The second (secondary) sort line sorts ascending (descending is the alternate option) alphabetically (numeric is the alternate option to alpha) on the system-defined (built-in) value "name", which is the filename without the path ("title" is another system-defined value).

Sort can be a command on its own, in which case it applies to the children of the file, after the document tree has been constructed in memory. The "Reference.txt" file sorts its children by name:

    #
    <!--
    * Sort: ascending alpha on name
    -->

This file also illustrates the use of a blank line beginning with the Markdown header indicator (number sign), to indicate that the system-defined "name" field should be used for the section title (with underscores replaced by spaces, as necessary). In this case, the section title will be "References".

The header for one of the "Stories" files illustrates how the user-defined property "Field" is defined:

    # 
    <!--
    + Field: Geology
    -->

The "Choose" and "Exclude" commands operate on user-defined properties. "Choose" only loads a file if the  property it references ("field" in this case) is not defined for the file, or the logical statement referencing the property is true for some setting of the property in the file (each property can have multiple settings). "Exclude" causes a file to not be loaded if the property it references is defined for the file, and the logical statement referencing the property is true for some setting of the property in the file. Logical statements use Perl's string and numeric operators.

There are two forms of the "Load from Refs" command, and both are illustrated in the example above.

    * Load from Refs: path Glossary using ../_Glossary/Glossary^*.txt
    * Load from Refs: no path using ../_References/References^*.txt

The first matches the specified path ("Glossary" in this case) to the path in each shorthand link statement encountered (see below for a description of shorthand link statements), and if it finds a match, it tries to load a file using the filename specification at the end of the statement. The filename specification must contain a asterisk character: the asterisk is replaced by the name (non-path part) of the link. Following is an example of a link with a path:

    <#Glossary^Bajada#>
    
In the example above, this link maps to the following filename:

    ../_Glossary/Glossary^Bajada.txt

The second form is the same as the first, except that it is for links that do not have a path. For example, the following link to a reference has no path:

    <#Leitner 2011 SDCNP#>

In the example above, this link maps to the following filename:

    ../_References/References^Leitner_2011_SDCNP.txt   

Refs can also be loaded from anchor blocks within a file. For example, a file Glossary~Complete.txt might contain anchor blocks for glossary entries like the following:

    <'Glossary^-A-'>
    **<"Glossary^Alluvial Fan">** "is a fan- or cone-shaped deposit
    of sediment crossed and built up by streams" 
    (<http://www.wikipedia.org/wiki/Bajada_(geography)>).

    <'Glossary^-B-'>
    **<"Glossary^Bajada">** "consists of a series of coalescing
    <#Glossary^alluvial fan#>s along a mountain front" 
    (<http://www.wikipedia.org/wiki/Alluvial_fan>).

An anchor block starts with a line containing a visible anchor. In the example above, the first visible anchor is:

    <"Glossary^Alluvial Fan">
    
The anchor block ends before the next line containing a visible or invisible anchor. In the example above, the first anchor block ends before the line with the following invisible anchor:

    <'Glossary^-B-'>

To make anchor blocks available for "Load from Refs" commands, the file containing them must appear in a "Split for Refs" command. The command for the Glossary~Complete.txt file, along with an appropriate "Load from Refs" command, is:

    * Split for Refs: Glossary~Complete.txt using Glossary^*
    * Load from Refs: path Glossary using Glossary^*

Each anchor is turned into a filename by taking the name portion of the anchor (ignoring the path) and substituting it for the asterisk in the filename specification at the end of the statement. These generated filenames can then be matched by the generated filenames in "Load from Refs" statements. If a match is found, the anchor block is fit into the hierarchy of sections based on the path in its generated filename.
    
In addition to document construction capabilities, scrappydox supports the following shorthand notations:

=over 20

=item <@filename@>

Inserts the contents of file "filename" after parsing it for other shorthand notations. Useful for template text containing variable references.

=item <"name">

Defines an HTML anchor with ID and title both set to "name".

=item <"^name">

Defines an HTML anchor with title "name" and ID set to the full path of the current file within the document, with "^name" appended.

=item <"prefix+name">

Defines an HTML anchor title set to "name" and ID set to "prefix+name". "prefix+" provides a namespace independent of the path hierarchy, as the path hierarchy does not contain plus signs.

=item <'anchor'>

Same as the double-quote HTML anchor notations above, except that no title is displayed.

=item <#link#>

Defines a link to any of the anchor-types defined above. The link will be the same as the anchor it links to, and follows the same rules for what will be displayed as the title of the link.

=item <*property*>

Is replaced by the named system-defined property. "Date" and "Name" are the only system-defined properties currently supported. "Name" is the portion of the filename after the caret-separated the path.

=item <+property+>

Is replaced by the named user-defined property.

=item <{r}text{r}>

Colors the enclosed text red.

=item <{g}text{g}>

Colors the enclosed text green.

=item <{b}text{b}>

Colors the enclosed text blue.

=item <{P}text{P}>

Sets the background of the enclosed text to pink.

=item <{Y}text{Y}>

Sets the background of the enclosed text to yellow.

=item <{B}text{B}>

Sets the background of the enclosed text to blue.

=item <{-}text{-}>

Sets the enclosed text to strikethrough font.

=back

Shorthand translation can be turned off for a file by setting the system property "process shorthand" to "0" in that file:

    <!--
    * Process Shorthand: 0
    -->
    
=head1 CAVEATS

The "Load from Refs" command works best when the file system is case insensitive as it is by default on Windows and Mac OS X. Otherwise, the refs will have to match case with the filename for the file to load; not great for glossary entries where the case of the ref should match the context of the ref.

To make "Load from Refs" work for all characters, characters in refs that are not allowed in filenames ('\', '/', ':', '*', '?', '"', '<', '>', '|') are URL-encoded; e.g. ':' becomes '%3a'. This means that the filenames must contain the URL-encoded characters. Filenames are URL-decoded before they are used to create user-display information, such as titles.

Both the need for a case insensitive operating system and the need to URL-encode special characters in filenames can be avoided by using the "Split for Refs" command to make reference targets available from anchor blocks within a file.

=head1 LICENSE

Copyright (c) 2015 Sam Gabriel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut

use strict;
use warnings;
use feature "fc";

if (@ARGV == 0) {
    print STDERR "scrappydox file...\n";
    exit 1;
}

# Significant chars
# Compiled regular expressions were causing problems. Colons
# and parentheses were not matching properly with $psr. The following
# definitions are used in comments to flag the locations where
# these special characters are used.
my $ps = '^'; # Path separator
#my $psr = qr/\^/; # Path separator regex
#my $dsr = qr/\+/; # Display separator regex
my $ii = '^^'; # ID indicator (use ID for URL)
my $ni = '^'; # name indicator (use name for URL)
my $ss = '_'; # Space substitute (in URLs and filenames)
#my $pbr = qr/^<!--\s*$/; # Begin properties section regex
#my $per = qr/^-->\s*$/; # End properties section regex

# Global Values
#my $currDate = dateString ("Datime");
my $currDate = dateString ("Std");

# Global Data Structures
my $root;
my %connectedFiles;
my %filesAtPath;
my %filesAtPartialPath;
my %fileForFilename;
my %fileForId;
my %fileForAnchor;
my %rootFilters;
my %rootLoadFromRefs;
my %rootSplitsForRefs;

# Find the root and file basics
foreach my $filename (@ARGV) {
    my $file = loadFile($filename, \%rootFilters, \%rootLoadFromRefs, \%rootSplitsForRefs);
    connectFile($file, \%rootFilters) if defined $file;
}

# Build a tree from paths
addChildren ($root, $$root{id}, $$root{isysvars}, $$root{iuservars});
#processTree ($root, 0, \&printFileWithIndent);
processTree ($root, 0, \&processFile);

sub loadFile
{
    my $filename = shift;
    my $parentFilters = shift;
    my $parentLoadFromRefs = shift;
    my $parentSplitsForRefs = shift;

    # No need to reprocess filename that has been seen before
    return if exists $fileForFilename{$filename};
    #print STDERR "Loading $filename\n";

    # First file is root ($root defined at end of first file processing)
    my $isRoot = !$root;

    # Head, Tail, and Extension Processing
    my ($filepath, $head, $middle, $tail, $ext) = $filename =~ /^(.*\/)?(.*\+)?(.*?)(~.*)?\.([^.]+)$/;
    die "Invalid filename (missing extension): $filename" unless defined $ext;
    die "Invalid filename (missing main body): $filename" unless defined $middle;

    my $searchPartialPaths = $middle =~ /\^$/; #$psr
    if ($searchPartialPaths) {
        $middle =~ s/\^$//; #$psr
    }
        
    # Anchor is filename in lower case without head or tail,
    #   and with spaces translated to underscores
    #   and with no initial path separator character
    my ($anchor) = $middle =~ /^\^?(.*)$/; #$psr
    $anchor = an($anchor);
    
    # Name is last string in path
    my ($name) = $middle =~ /([^^]+)$/; #$psr
    die "Invalid filename: $filename" unless defined $name;
    
    # Determine ID from $middle
    my $id;
    if ($isRoot) {
        # Remove any initial path separator character
        $id = $middle =~ s/^\^//r; #$psr
    }
    else {
        # Extend non-root IDs that start with path separator character
        if ($middle =~ /^\^/) { #$psr
            $id = $$root{id} . $middle;
        }
        # Extend non-root IDs that have no path
        elsif (!($middle =~ /\^/)) { #$psr
            $id = $$root{id} . $ps . $middle;
        }
        else {
            $id = $middle;
        }
    }

    # Determine path
    my ($path) = $id =~ /(.+)\^[^^]+$/; #$psr
    if (!defined($path)) {
        $path = '';
    }

    # Begin file operations
    my $prefix;
    my $title;
    my @syscmds;
    my %sysvars;
    my %uservars;
    open (my $fh, '<', $filename) or die "Can't open $filename: $!";
    
    # Obtain information from first line of file
    if (defined($_ = <$fh>)) {
        if (!readProperties(\@syscmds, \%sysvars, \%uservars, $fh, $_)) {
            ($prefix, $title) = /^(#+)\s*(.*?)\s*$/;

            # Check second line of file for properties section
            if (defined($_ = <$fh>)) {
                readProperties(\@syscmds, \%sysvars, \%uservars, $fh, $_);
            }
        }
    }
    #print STDERR "For $filename prefix is not defined\n" if not defined $prefix;
    $prefix = $prefix ? $prefix : "";  
    $title = $title ? $title : titleFromName($name);
    #print STDERR "$filename $prefix $title\n";
    
    # Set up loadFromRefs
    my $loadFromRefs = $isRoot ? $parentLoadFromRefs : {%$parentLoadFromRefs};
    if (exists $sysvars{'load from refs'}) {
        foreach my $val (@{$sysvars{'load from refs'}}) {
            if ($val =~ /^no\s+path\s+using\s+(\S+)$/i) {
                $$loadFromRefs{''} = $1;
            }
            elsif ($val =~ /^path\s+(\S+)\s+using\s+(\S+)$/i) {
                $$loadFromRefs{$1} = $2;
            }
        }
    }
    
    # Process post-header contents based on loadFromRefs
    my @refdFilesToLoad;
    if (keys %$loadFromRefs) {
        while (<$fh>) {
            addRefdFilesToLoad($_, $loadFromRefs, \@refdFilesToLoad);
        }
    }

    # End file operations
    close $fh;
    
    # Set up and process splitsForRefs using loadFromRefs
    my $splitsForRefs = $isRoot ? $parentSplitsForRefs : {%$parentSplitsForRefs};
    if (exists $sysvars{'split for refs'}) {
        foreach my $val (@{$sysvars{'split for refs'}}) {
            if ($val =~ /(\S+)\s+using\s+(\S+)/) {
                my $filename = $1;
                my $template = $2;
                splitFileForRefs($filename, $template, $loadFromRefs, $splitsForRefs);
             }
       }
    }
    
    # Apply filters
    foreach my $uservarname (keys %uservars) {
        if (exists $$parentFilters{$uservarname}) {
            my $hasChoices = 0;
            my $foundTrue = 0;
            foreach my $filter (@{$$parentFilters{$uservarname}}) {
                my $op = $$filter{op};
                my $val = $$filter{val};
                my $isChoose = $$filter{isChoose};
                my $isExclude = $$filter{isExclude};
                $hasChoices = 1 if $isChoose;
                foreach my $userval (@{$uservars{$uservarname}}) {
                    if (boolEval($userval, $op, $val)) {
                        if ($isExclude) {
                            return;
                        }
                        $foundTrue = 1;
                    }
                }
            }
            return if $hasChoices and not $foundTrue;
       }
    }
    
    # Anchor must be unique: ignore the file if it matches an existing anchor;
    if (exists $fileForAnchor{$anchor}) {
        print STDERR "Ignoring \"$filename\": duplicate anchor (internal link target)\n";
        #return $fileForAnchor{$anchor};
        return;
    }
    
    # Make sure ID is unique (should have been caught with anchor test above)
    die "Duplicate ID: $id" if exists $fileForId{$id};
    
    # Bundle information about file in hash
    my %file;
    $file{isRoot} = $isRoot;
    $file{filename} = $filename;
    $file{head} = $head;
    $file{tail} = $tail;
    $file{id} = $id;
    $file{searchPartialPaths} = $searchPartialPaths;
    $file{anchor} = $anchor;
    $file{name} = $name;
    $file{titlePrefix} = $prefix;  
    $file{title} = $title;
    $file{syscmds} = \@syscmds;
    $file{sysvars} = \%sysvars;
    $file{isysvars} = \%sysvars if $isRoot; # Inherited sysvars
    $file{uservars} = \%uservars;
    $file{iuservars} = \%uservars if $isRoot; # Inherited uservars
    $file{path} = $path;
    $file{loadFromRefs} = $loadFromRefs;
    $file{refdFilesToLoad} = \@refdFilesToLoad;
    $file{splitsForRefs} = $splitsForRefs;

    # Define first file as root
    $root = \%file if $isRoot;

    # Add the file to fileForAnchor
    $fileForAnchor{$anchor} = \%file;
    
    # Add to fileForId
    $fileForId{$id} = \%file;
    
    # Add to fileForFilename
    $fileForFilename{$filename} = \%file;
    
    return \%file;
}

sub connectFile
{
    my $file = shift;
    my $parentFilters = shift;
    my $id = $$file{id};
    
    return if exists $connectedFiles{$id}; # Prevent circular refs
    $connectedFiles{$id} = undef; # undef is lowest footprint value
    
    my $isRoot = $$file{isRoot};
    my $path = $$file{path};
    my $syscmds = $$file{syscmds};
    my $loadFromRefs = $$file{loadFromRefs};
    my $refdFilesToLoad = $$file{refdFilesToLoad};
    my $splitsForRefs = $$file{splitsForRefs};
    #printf STDERR "Connecting $$file{filename} $path\n";
    
    # Add to filesAtPath
    if (exists $filesAtPath{$path}) {
        push @{$filesAtPath{$path}}, $file;
     }
    else {
       $filesAtPath{$path} = [$file];
    }

    # Add to filesAtPartialPath
    my ($partialPath) = $path =~ /^([^^]+)\^/; #$psr
    if ($partialPath) {
        # print STDERR "Partial path: $partialPath\n";
        if (exists $filesAtPartialPath{$partialPath}) {
            push @{$filesAtPartialPath{$partialPath}}, $file;
         }
        else {
           $filesAtPartialPath{$partialPath} = [$file];
        }
    }
    
    # Process syscmds for filters, and to load children and other files in order
    my @children;
    # Root filters apply to all subsequent files loaded in the same list with root:
    my $filters = $isRoot ? $parentFilters : {%$parentFilters};
    foreach my $syscmd (@{$syscmds}) {
        my $cmd = $$syscmd{cmd};
        my $arg = $$syscmd{arg};
        my $switches = $$syscmd{switches};
        if ($cmd eq 'choose' || $cmd eq 'exclude') {
            my ($var, $op, $val) = $arg =~ /^(.+?)\s+(==|!=|<|>|<=|>=|eq|ne|lt|gt|le|ge)\s+(.+?)$/;
            if (defined $op) {
                $var =~ s/\s+/ /g;
                $var = lc $var;
                my %filter = (
                    'op' => $op,
                    'val' => $val,
                    'isChoose' => $cmd eq 'choose',
                    'isExclude' => $cmd eq 'exclude',
                );
                addToHash($filters, $var, \%filter);
            }
        }
        elsif ($cmd eq 'child' || $cmd eq 'load') {
            my @files;
            foreach my $filename (glob $arg) {
                my $file = loadFile($filename, $filters, $loadFromRefs, $splitsForRefs);
                push @files, $file if defined $file;
            }
            foreach my $switch (reverse @{$switches}) {
                if ($switch =~ /^sort\s*:\s+reverse$/i) {
                    @files = reverse @files;
                }
                elsif ($switch =~ /^sort\s*:\s+(ascending|descending)\s+(alpha|numeric)\s+(on|using)\s+(.+)$/i) {
                    @files = sortFiles(\@files, lc $1 eq 'ascending', lc $2 eq 'alpha', lc $3 eq 'on', lc $4);
                }
            }
            foreach my $file (@files) {
                connectFile($file, $filters);
                push @children, $file if $cmd eq 'child';
            }
        }
    }
    $$file{children} = \@children if @children;
    
    # Load referenced files
    foreach my $refdFile (@{$refdFilesToLoad}) {
        #print STDERR "Loading $refdFile\n";
        my $lcRefdFile = lc($refdFile);
        my $file = exists $$splitsForRefs{$lcRefdFile} ? $$splitsForRefs{$lcRefdFile} : loadFile($refdFile, $filters, $loadFromRefs, $splitsForRefs);
        connectFile($file, $filters) if defined $file;
    }
}

sub sortFiles
{
    my $files = shift;
    my $isAscending = shift;
    my $isAlpha = shift;
    my $isSystem = shift;
    my $field = shift;
    my $sortByName = 0;
    my $sortByTitle = 0;
    if ($isSystem) {
        if ($field eq 'name') {
            $sortByName = 1;
        }
        elsif ($field eq 'title') {
            $sortByTitle = 1;
        }
        else {
            next;
        }
    }
    foreach my $file (@{$files}) {
        my $sortkey;
        if ($sortByName) {
            $sortkey = $$file{name};
        }
        elsif ($sortByTitle) {
            $sortkey = $$file{title};
        }
        else {
            my $uservars = $$file{uservars};
            if (exists $$uservars{$field}) {
                # First key is probably main one
                $sortkey = $$uservars{$field}[0];
            }
            else {
                $sortkey = "";
            }
        }
        $$file{sortkey} = $sortkey;  
    }
    my $sortfn;
    if ($isAscending) {
        if ($isAlpha) {
            $sortfn = \&sortAscendingAlpha;
        }
        else {
            $sortfn = \&sortAscendingNumeric;
        }
    }
    else {
        if ($isAlpha) {
            $sortfn = \&sortDescendingAlpha;
        }
        else {
            $sortfn = \&sortDescendingNumeric;
        }
    }
    return sort $sortfn @{$files};
}

sub sortAscendingAlpha {
    $$a{sortkey} cmp $$b{sortkey};
}

sub sortDescendingAlpha {
    $$b{sortkey} cmp $$a{sortkey};
}

sub sortAscendingNumeric {
    $$a{sortkey} <=> $$b{sortkey};
}

sub sortDescendingNumeric {
    $$b{sortkey} <=> $$a{sortkey};
}

sub readProperties
{
    my $syscmds = shift;
    my $sysvars = shift;
    my $uservars = shift;
    my $fh = shift;
    my $line = shift;
    if ($line =~ /^<!--\s*$/) { #$pbr
        my $lastSyscmd;
        while (<$fh>) {
            last if (/^-->\s*$/); #$per
            next if (/^\s*$/);
            if (/^\s{0,3}([*+])\s+(.*?)\s*:\s+(.*?)\s*$/) {
                my $hash = $1 eq '*' ? $sysvars : $uservars;
                addToHash($hash, lc($2), $3);
                if ($1 eq '*') {
                    my %syscmd = (
                        'cmd' => lc($2),
                        'arg' => $3,
                        'switches' => [],
                    );
                    push @{$syscmds}, \%syscmd;
                    $lastSyscmd = \%syscmd;
                }
                else {
                    undef $lastSyscmd;
                }
            }
            elsif (defined $lastSyscmd && /^\s{4,7}-\s+(.*?)\s*$/) {
                push @{$$lastSyscmd{switches}}, $1;
            }
        }
        return 1;
    }
    return 0;
}

sub addRefdFilesToLoad
{
    my $line = shift;
    my $loadFromRefs = shift;
    my $refdFilesToLoad = shift;
    while ($line =~ /<#([^#+]+\^)?([^#+^]+)#>/g) { #$psr
        my $path = !defined $1 ? '' : $1;
        chop $path;
        my $name = nameFromTitle($2);
        #print STDERR "Name to load: $name\n";
        if (exists $$loadFromRefs{$path}) {
            my $template = $$loadFromRefs{$path};
            my $refFileName = $template =~ s/\*/$name/r;
            push @$refdFilesToLoad, $refFileName;
            #print STDERR "Ref to load: $refFileName\n";
        }
    }
}

sub splitFileForRefs
{
    my $filename = shift;
    my $template = shift;
    my $loadFromRefs = shift;
    my $splitsForRefs = shift;
    my $file;
    open (my $fh, '<', $filename) or die "Can't open $filename: $!";
    while (<$fh>) {
        if (/<(["'])(.+?)\1>/) {
            my $char = $1;
            my $body = $2;
            if (defined $file) {
                # This visible or invisible anchor block wraps
                # up processing of previous visible anchor block
                $$splitsForRefs{lc($$file{filename})} = $file;
                undef $file;
            }
            if ($char eq '"') {
                # Start processing visible anchor block
                my ($origPath, $title) = $body =~ /(.+\^)?([^^]+)/;
                my $name = nameFromTitle($title);
                my $filename = $template =~ s/\*/$name/r;
                my ($filepath, $head, $id, $tail, $ext) = $filename =~ /^(.*\/)?(.*\+)?(.*?)(~.*)?(\.[^.]+)?$/;
                die "Invalid filename for reference (missing main body): $filename" unless defined $id;
                my ($anchor) = an($id);
                my ($path) = $id =~ /(.+)\^[^^]+$/; #$psr
                $path = '' if not defined $path;
                $file = {
                    isRoot => 0,
                    filename => $filename,
                    id => $id,
                    anchor => $anchor,
                    name => $name,
                    titlePrefix => '',
                    title => $title,
                    syscmds => [],
                    sysvars => {},
                    uservars => {},
                    path => $path,
                    lines => [$_],
                    loadFromRefs => $loadFromRefs,
                    refdFilesToLoad => [],
                    splitsForRefs => $splitsForRefs,
                };
                addRefdFilesToLoad($_, $loadFromRefs, $$file{refdFilesToLoad});
            }
        }
        elsif (defined $file) {
            push @{$$file{lines}}, $_;
            addRefdFilesToLoad($_, $loadFromRefs, $$file{refdFilesToLoad});
        }
    }
    if (defined $file) {
        $$splitsForRefs{lc($$file{filename})} = $file;
        undef $file;
    }
    close $fh;
    #foreach my $key (keys %$splitsForRefs) {
    #    print STDERR "$key\n";
    #}
}

sub addChildren
{
    my $file = shift;
    my $fullPath = shift;
    my $psysvars = shift; # Parent sysvars
    my $puservars = shift; # Parent sysvars
    
    # Determine and save the inherited sysvars
    my %isysvars = %{$psysvars};
    my $sysvars = $$file{sysvars};
    @isysvars{keys %{$sysvars}} = values %{$sysvars};
    $$file{isysvars} = \%isysvars;
    
    # Determine and save the inherited uservars
    my %iuservars = %{$puservars};
    my $uservars = $$file{uservars};
    @iuservars{keys %{$uservars}} = values %{$uservars};
    $$file{iuservars} = \%iuservars;
    
    # Save fullPath
    $$file{fullPath} = $fullPath;
    
    # Process explicit children
    if (exists $$file{children}) {
        foreach my $child (@{$$file{children}}) {
            addChildren ($child, $fullPath . $ps . $$child{name}, \%isysvars, \%iuservars);
        }
    }
    else {
        my @children = ();  
        my $searchPath = $fullPath;
        while ($searchPath) {
            if (exists $filesAtPath{$searchPath}) {
                my $files = $filesAtPath{$searchPath};
                push @children, @{$files};
                foreach my $child (@{$files}) {
                    addChildren ($child, $fullPath . $ps . $$child{name}, \%isysvars, \%iuservars);
                }
            }
            $searchPath =~ s/[^^]*\^?//; #$psr
        }
        if ($$file{searchPartialPaths} && !@children) {
            # Search partial paths
            my $name = $$file{name};
            if (exists $filesAtPartialPath{$name}) {
                my $files = $filesAtPartialPath{$name};
                push @children, @{$files};
                foreach my $child (@{$files}) {
                    my $childFullPath = $fullPath . ($$child{id} =~ s/^[^^]+//r); #$psr
                    addChildren ($child, $childFullPath, \%isysvars, \%iuservars);
                }
            }
        }
        $$file{children} = \@children;
        #foreach my $child (@children) {
        #    print STDERR "$$file{filename} <- $$child{filename} $$child{titlePrefix}\n";
        #}
    }
    
    # Sort the children
    if (@{$$file{children}} > 1) {
        my $sysvars = $$file{sysvars};
        if (exists $$sysvars{sort}) {
            my $sorts = $$sysvars{sort};
            my @files = @{$$file{children}};
            foreach my $sort (reverse @{$sorts}) {
                if ($sort =~ /^reverse$/i) {
                    @files = reverse @files;
                }
                elsif ($sort =~ /^(ascending|descending)\s+(alpha|numeric)\s+(on|using)\s+(.+)$/i) {
                    @files = sortFiles(\@files, lc $1 eq 'ascending', lc $2 eq 'alpha', lc $3 eq 'on', lc $4);
                }
            }
            $$file{children} = \@files;
        }
    }
}

sub processTree
{
    my $file = shift;
    my $indent = shift;
    my $f = shift;
    $f->($file, $indent);
    
    my $childIndent = $indent;
    if (!exists $$file{titlePrefix} || $$file{titlePrefix}) {
        ++$childIndent;
    }
    foreach my $child (@{$$file{children}}) {
        processTree ($child, $childIndent, $f);
    }
}

# This sub is only called for debugging purposes
sub printFileWithIndent
{
    my $file = shift;
    my $indent = shift;

    my $indentString = '    ' x $indent;
    print $indentString . $$file{name} . "\n";
}

sub processFile
{
    my $file = shift;
    my $indent = shift;
    
    # Set up file variables
    my $isRoot= $$file{isRoot};
    my $filename = $$file{filename};
    my $name = $$file{name};
    my $titlePrefix = $$file{titlePrefix};
    my $sysvars = $$file{sysvars};
    my $processShorthand = exists $$sysvars{"process shorthand"} ? ( lc @{$$sysvars{"process shorthand"}}[-1] eq "no" ? 0 : 1 ) : 1;
    my $prefixAdjustment = 0;
    my $toc = '';
    if ($isRoot || $titlePrefix) {
        $prefixAdjustment = 1 - length $titlePrefix;
        $prefixAdjustment += $indent;

        # Generate table of contents for children
        my $children = $$file{children};
        my $nChildrenWithPrefix = 0;
        foreach my $child (@{$children}) {
            ++$nChildrenWithPrefix if $$child{titlePrefix};
        }

        if ($nChildrenWithPrefix) {
            $toc .= "\n\n";
            $toc .= "************\n\n";
            $toc .= "**Contents**\n\n";
            foreach my $child (@{$children}) {
                if ($$child{titlePrefix}) {
                    $toc .= "[" . $$child{title} . "]";
                    $toc .= "(#" . $$child{anchor} . ")  \n";
                }
            }
            $toc .= "\n";
            $toc .= "************\n\n";
            $toc .= "<br/>\n\n";
        }
    }

    # Process file contents
    my $ignoringProperties = 0;
    if (exists $$file{lines}) {
        my $lineNumber = 0;
        foreach my $line (@{$$file{lines}}) {
            procLine($file, $line, ++$lineNumber, $prefixAdjustment, $processShorthand, \$ignoringProperties);
        }
    }
    else {
        open (my $fh, '<', $filename) or die "Can't open $filename: $!";
        while (<$fh>) {
            procLine($file, $_, $., $prefixAdjustment, $processShorthand, \$ignoringProperties);
        }
        close $fh;
    }
    print $toc;
    
    # Prevent merge of last line of file with first line of next file
    print "\n\n";
}

sub procLine
{
    my $file = shift;
    my $line = shift;
    my $lineNumber = shift;
    my $prefixAdjustment = shift;
    my $processShorthand = shift;
    my $ignoringProperties = shift;
    my $anchor = $$file{anchor};
    my $titlePrefix = $$file{titlePrefix};
    my $title = $$file{title};
    # Skip through properties section
    if ($$ignoringProperties) {
        $$ignoringProperties = 0 if $line =~ /^-->\s*$/; #$per
        return;
    }
    
    if ($lineNumber == 1) {
        # Add anchor if first line with prefix
        if ($titlePrefix) {
            # Add anchor and title
            $line =~ s/^(#*).*$/$1 <span id="$anchor">$title<\/span> /;
        }
        if ($line =~ /^<!--\s*$/) { #$pbr
            $$ignoringProperties = 1;
            return;
        }
    }
    elsif ($lineNumber == 2 && !$$ignoringProperties) {
        if ($line =~ /^<!--\s*$/) { #$pbr
            $$ignoringProperties = 1;
            return;
        }
    }
    
    # Correct prefix lengths      
    my ($prefix, $body) = $line =~ /^(#*)(.*?)[\r\n]*$/;
    if ($prefix && $titlePrefix) {
        print '#' x ($prefixAdjustment + length $prefix)
    }
    
    # Make sure there is a body
    $body = "" if not $body;
    
    # Process angle-bracket shorthands
    procShorthand($file, \$body) if $processShorthand;
    
    print $body . "\n";
}

sub procShorthand
{
    my $file = shift;
    my $bodyref = shift;
    $$bodyref =~ s/<([@"'#*+]|\{[rgbPYB-]\})(.+?)\1>/proc($file, $1, $2)/eg;
}

sub procVarShorthand
{
    my $file = shift;
    my $bodyref = shift;
    $$bodyref =~ s/<([*+])(.+?)\1>/proc($file, $1, $2)/eg;
}

sub proc
{
    my $file = shift;
    my $char = shift;
    my $body = shift;
    if ($char eq '@') { # File to include
        open (my $fh, '<', $body) or die "Can't open $body: $!";
        if (defined $fh) {
            my $includedOutput;
            while (my $line = <$fh>) {
                procShorthand($file, \$line);
                $includedOutput .= $line;
            }
            close $fh;
            return $includedOutput;
        }
        return '';
    }
    if ($char eq '"' or $char eq "'") { # Anchor
        my $display;
        my $url;
        if ($body eq $ii) {
            # Anchor is the file anchor (based on ID)
            my $name = $$file{name};
            $url = $$file{anchor};
            $display = titleFromName($name);
        }
        elsif ($body eq $ni) {
            # Anchor is name
            my $name = $$file{name};
            $url = an($name);
            $display = titleFromName($name);
        }
        else {
            # Anchor is a regular path
            procVarShorthand($file, \$body);
            my @pathParts = split /\^/, $body; #$psr
            $display = (split /\+/, $pathParts[-1])[-1] =~ s/$ss/ /gr; #$dsr
            if (!$pathParts[0]) {
                # Starts with path separator:
                # In-file nested anchor
                $url = $$file{anchor} . an($body);
            }
            else {
                # Doesn't start with path separator
                # Anchor is standard non-nested anchor
                $url = an($body);
            }
        }
        $display = '' if $char eq "'";
        return "<span id=\"$url\">$display<\/span>";
    }
    if ($char eq '#') { # Link
        procVarShorthand($file, \$body);
        my @pathParts = split /\^/, $body; #$psr
        my $display = (split /\+/, $pathParts[-1])[-1] =~ s/$ss/ /gr; #$dsr
        my $url;
        #print STDERR $char . ' ' . $display . "\n";
        if (!$pathParts[0]) {
            # Starts with path separator:
            # In-file nested link
            $url = $$file{anchor} .  an($body);
        }
        else {
            # Doesn't start with path separator
            # Non-nested link
            $url = an($body);
            if (exists $fileForAnchor{$url}) {
                my $title = ${$fileForAnchor{$url}}{title};
                # To preserve case of link, only use title if more than case is different
                if (fc $title ne fc $display) {
                    $display = $title;
                }
            }
        }
        return "<a href=\"#$url\">$display</a>";
    }
    if ($char eq '{r}') { # Red foreground font
        procShorthand($file, \$body);
        return "<span style=\"color: red\">$body</span>";
    }
    if ($char eq '{g}') { # Green foreground font
        procShorthand($file, \$body);
        return "<span style=\"color: green\">$body</span>";
    }
    if ($char eq '{b}') { # Blue foreground font
        procShorthand($file, \$body);
        return "<span style=\"color: blue\">$body</span>";
    }
    if ($char eq '{P}') { # Pink background color
        procShorthand($file, \$body);
        return "<span style=\"background-color: pink\">$body</span>";
    }
    if ($char eq '{Y}') { # Yellow background color
        procShorthand($file, \$body);
        return "<span style=\"background-color: yellow\">$body</span>";
    }
    if ($char eq '{B}') { # Blue background color
        procShorthand($file, \$body);
        return "<span style=\"background-color: aqua\">$body</span>";
    }
    if ($char eq '{-}') { # Sriked-out text
        procShorthand($file, \$body);
        return "<span style=\"text-decoration: line-through\">$body</span>";
    }
    if ($char eq '*') { # System variable
        my $sysvarname = lc $body;
        if ($sysvarname eq 'date') {
            return $currDate;
        }
        if ($sysvarname eq 'name') {
            return $$file{name};
        }
    }
    elsif ($char eq '+') { # User variable
        my $uservarname = lc $body;
        my $uservars = $$file{uservars};
        if (exists $$uservars{$uservarname}) {
            return @{$$uservars{$uservarname}}[-1];
        }
        # Unrecognized user variable: silently return empty string.
        # Returning empty string supports notion that user variables
        # are optional.
        return '';
    }
    # Unrecognized shorthand: return original string
    return "<$char$body$char>";
}

sub addToHash
{
    my $hash = shift;
    my $key = shift;
    my $value = shift;
    if (exists $$hash{$key}) {
        push @{$$hash{$key}}, $value;
    }
    else {
        $$hash{$key} = [$value];
    }
}

# This subroutine is a safer alternative to an eval statement
sub boolEval
{
    my $left = shift;
    my $op = shift;
    my $right = shift;
    if ($op eq 'eq') {
        return $left eq $right;
    }
    if  ($op eq 'ne') {
        return $left ne $right;
    }
    if  ($op eq 'gt') {
        return $left gt $right;
    }
    if  ($op eq 'lt') {
        return $left lt $right;
    }
    if  ($op eq 'ge') {
        return $left ge $right;
    }
    if  ($op eq 'le') {
        return $left le $right;
    }
    if  ($op eq '==') {
        return $left == $right;
    }
    if  ($op eq '!=') {
        return $left != $right;
    }
    if  ($op eq '>') {
        return $left > $right;
    }
    if  ($op eq '<') {
        return $left < $right;
    }
    if  ($op eq '>=') {
        return $left >= $right;
    }
    if  ($op eq '<=') {
        return $left <= $right;
    }
    return 0;
}

sub dateString
{
    my $type = shift;
    my @month = qw(
        January
        February
        March
        April
        May
        June
        July
        August
        September
        October
        November
        December
    );
    my @dow = qw(
        Sunday
        Monday
        Tuesday
        Wednesday
        Thursday
        Friday
        Saturday
    );
    my @sdow = qw(
        Su
        Mo
        Tu
        We
        Th
        Fr
        Sa
    );
    my $monthAlternatives = join '|', @month;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    if ($type eq "Std") {
        return sprintf("%04d-%02d-%02d %2s %02d%02d", $year + 1900, $mon + 1, $mday, $sdow[$wday], $hour, $min);    
    }
    my $date = $mday . ' ' . $month[$mon] . ' ' . ($year + 1900);
    my $dow = $dow[$wday];
    my $time = sprintf("%02d%02d", $hour, $min);
    my $datime = $date . ' ' . $time;
    my $fullDatime = $dow . ', ' . $datime;
    if ($type eq "Full") { return $fullDatime };
    if ($type eq "Datime") { return $datime };
    return $datime;
}

sub urlDecode
{
    # Performs standard URL decoding, where encoding is indicated by percent signs.
    my $url = shift;
    $url =~ s/%([A-Fa-f\d]{2})/ chr hex $1 /eg;
    return $url;
}

sub an
{
    # Special characters need to be encoded for anchors. As anchors
    # appear both in id tag attributes and in URLs, URL-style
    # encoding does not work properly. Instead, URL-style encoding
    # is modified to use period instead of percent. Period is a good
    # choice because it is not a special character in URLs, and it is
    # allowable in HTML4 ID attributes. Periods themselves are encoded.
    #
    # The name (not path) portion of the input to this subroutine may use
    # URL encoding, so URL decoding is performed on the name first.
    my $anchor = shift;
    $anchor =~ s/([^^]+)$/ urlDecode($1) /e; #$psr
    $anchor =~ s/ /$ss/g; # substitute spaces
    $anchor =~ s/([:;,.!?%@&#*=~\$'"\\\/()<>{}[\]])/ sprintf ".%02x", ord $1 /eg;
    return (lc $anchor);
}

sub titleFromName
{
    # The name portion of filenames can use standard URL encoding.
    # The algorithm here applys that standard URL decoding, plus
    # translation of underscores to spaces.
    my $title = shift;
    $title =~ s/$ss/ /g;
    return urlDecode($title);
}

sub nameFromTitle
{
    # "Name" refers to the non-path (right-most) portion of a scrappydox filename,
    # where the path is the scrappydox path, separated by caret characters. This
    # routine encodes characters that are illegal in Windows filenames. Illegal Windows
    # filename characters are `\/:*?"<>|`. These characters are URL-encoded, and spaces
    # are translated to underscores. Windows is more restrictive than Mac OS X,
    # so its list of invalid characters was used for this translation.
    my $filename = shift;
    $filename =~ s/ /$ss/g;
    $filename =~ s/([\\\/:*?"<>|])/ sprintf "%%%02x", ord $1 /eg;
    return $filename;
}


