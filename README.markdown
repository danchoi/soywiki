# SoyWiki

SoyWiki is fast, lightweight, Vim-centric wiki application. A quick
overview of its characteristics and features:

* flat text files
* maximum data portability
* high interoperability with Unix tools
* Vim text editing power
* super-efficient modes of wiki traversal 
* Git for versioning, distributed workflows, and blaming
* CamelCase wiki words
* namespaced wiki words
* autocompletion of wiki words
* automated global renaming of wiki words
* syntax colored wiki words
* outliner-like capability with expand-command 
* operates on all POSIX systems (e.g. OS X, Linux, FreeBSD)


## Introduction

By building on Vim's strengths as a text editor and interface to the
Unix operating system, SoyWiki makes it possible to create, consult, and
refactor wiki content at the speed of thought. 

SoyWiki is good for tracking projects, contacts, ideas, and collecting
research. 

SoyWiki serves as a writing aid and makes it easy to take full advantage
of a large monitor and Vim's split windows. You can have the research
material you've collected in SoyWiki open in one or more windows, the
essay or paper you're drafting open in another, and all the power of
Vim's yank, put, and mark commands to shuttle text between them.

Because SoyWiki's content is stored in plain text files, you can
directly process, filter, grep, copy, and move text in and out of your
wiki using any combination of Unix tools.

SoyWiki delegates practically all of its revision-tracking and
distributed collaboration features to Git.  SoyWiki automatically
creates a git repository in your wiki directory and automatically
commits all the edits you make to it.  You can sync a SoyWiki wiki
between two computers using the standard git push and pull commands.
Collaborators can also edit a common wiki this way, in peer to peer
fashion. SoyWiki provides a few convenient key mappings to view the
revision history of a wiki page and to see a "git-blame" view of who
wrote each line when.

SoyWiki doesn't have a web interface yet. The main focus of SoyWiki at
this stage is to help you organize knowledge and evolve it with minimal
annoyance and distraction.  

SoyWiki uses CamelCase -- a.k.a. WikiCase -- to link wiki pages
together.  Besides being the original, CamelCase is the most elegantly
minimalist approach to linking wiki pages together -- "with no
additional markup whatsoever," as [Ward Cunningham put it][ward].  It
encourages you to create wiki pages with succinctly descriptive names.
CamelCase wiki-links are also better when storing content in plain text
files: the page names can map directly to Unix file names without any
awkward character escaping.

[ward]:http://c2.com/cgi/wiki?WikiCase

I enjoy soy ice cream, soy milk, and tofu -- all light, enjoyable, and
healthy foods. And "SoyWiki" hasn't been used yet to name a wiki engine.
Hence the name.


## Prerequisites

* a recent version of Vim (SoyWiki is developed against Vim 7.2 and 7.3)
* a recent version of Ruby (SoyWiki is developed using Ruby 1.9.2)
* RubyGems (if Ruby version is older than 1.9)
* a recent version of git (1.7.0.4 or above to be safe)

The current version of SoyWiki assumes a Unix environment. 

To use SoyWiki you should be fairly good at using Vim. More than 80
percent of the SoyWiki codebase implements the VimScript interface
layer.


## Installation

    gem install soywiki

Test your installation by typing `soywiki -h`. You should see SoyWiki's help.

On some systems you may run into a PATH issue, where the system can't find the
`soywiki` command after installation. Please report this if you encounter this
problem, and mention what system you're using. You might want to try 

    sudo gem install soywiki

If you ever want to uninstall SoyWiki from your system, execute this command:

    gem uninstall soywiki

... and all traces of SoyWiki will removed.

## Starting SoyWiki

Once you've created the configuration file and (optionally) the contacts file,
you can start SoyWiki with

    soywiki

## Using SoyWiki


TO BE FINISHED


SoyWiki requires you to learn only a tiny, nearly
non-existent markup language.  To make a piece of text work with
SoyWiki, it just needs to use CamelCase WikiWords.  Beyond that, you can
mark up your text any way you want, using Markdown, Texttile, AsciiDoc,
or nothing.

## Opening hyperlinks and HTML parts in your web browser

When you're reading a message, `,o` opens the first hyperlink in the email

By default, the vmail uses the command `open` or `gnome-open` to launch your
web browser. In OS X, `open` opens URLs and HTML files in the default web
browser.  `gnome-open` does the same in the Gnome Linux environment.  You can
change the command SoyWiki uses to open a hyperlink by adding this to your
.vimrc:

    let g:SoyWiki#browser_command = "your browser command here"

If your Vim has `netrw` (`:help netrw`), you can open a hyperlink directly in
same Vim window by putting the cursor at the beginning of a hyperlink and
typing `gf`, or `C-w f` if you want to open the webpage in a split window. 


