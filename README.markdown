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

What is easy for the beginner is often not efficient for the proficient
user.  This is especially so when wikis force everyone to do everything
through a web-browser interface.  Web browser interfaces are not
terrible.  But the difference between using a web browser interface to
edit and navigate textual content and using a real text editor in a
full-fledged Unix environment is like the difference between crawling
and doing gymnastics.

The text editing and wiki link traversal facilities of SoyWiki far outstrip
those of your typical web-browser-based wiki.  By building on Vim's
existing strengths as a text editor and interface to the Unix operating
system, SoyWiki makes it possible to create, consult, and remold wiki
content pretty much at the speed of thought. This is SoyWiki's primary
mission.

SoyWiki excels as a personal wiki. It is very good for tracking
projects, contacts, ideas, and collecting research. 

SoyWiki serves as a writing tool as well. It has an "expand-command"
that allows you to use wiki pages in a fashion essentially similar to
(and some might say more powerful than) an outline and generate an
"expanded-view" that bundles together several wiki pages into a single
long-form document.  SoyWiki makes it easy to take full advantage of a
large monitor and Vim's split windows. You can have the research
material you've collected in SoyWik open in one or more windows, the
essay or paper you're drafting open in another, and all the 
power of Vim's yank, put, and mark commands to shuttle bits of text
between them.

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

Will there ever be a web browser interface to SoyWiki? Maybe. If you're
a software developer feel free to contribute. But the main focus on
SoyWiki at this stage is not on making it easy to publish and manage a
public-facing wiki. The main focus right now is to help you organize
knowledge and evolve it with minimal annoyance and distraction.  (Still,
if you want to publish any of the content in a SoyWiki wiki, it's
relatively easy to write a program that will bundle up all the relevant
wiki pages together and convert them into public-facing webpages.)

There are many syntaxes for linking wiki pages together. Why does
SoyWiki opt for CamelCase (a.k.a. the WikiCase link pattern)? Besides
being the original, CamelCase is the most elegantly minimalist approach
to linking wiki pages together -- "with no additional markup
whatsoever," as [Ward Cunningham put it][ward].  It encourages you to
create wiki pages with succinctly descriptive names.  CamelCase
wiki-links are also better when storing content in plain text files: the
page names can map directly to Unix file names without any awkward
character escaping.

[ward]:http://c2.com/cgi/wiki?WikiCase

I enjoy soy ice cream, soy milk, and tofu--all light, enjoyable, and
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


