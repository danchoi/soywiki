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
* syntax colored WikiWords
* outliner-like capability with expand-command 
* operates on all POSIX systems (e.g. OS X, Linux, FreeBSD)

The current version of SoyWiki expects you to be fairly good at using
Vim. More than 80 percent of the SoyWiki codebase implements the
VimScript interface layer.

On the other hand, SoyWiki requires you to learn only a tiny, nearly
non-existent markup language.  To make a piece of text work with
SoyWiki, it just needs to use CamelCase WikiWords.  Beyond that, you can
mark up your text any way you want, using Markdown, Texttile, AsciiDoc,
or nothing.

## Introduction

What is easy for the beginner is often not efficient for the proficient
user.  This is especially so when wikis force everyone to do everything
through a web-browser interface.  Web browser interfaces are not
terrible.  But the difference between using a web browser interface to
edit and navigate textual content and using a real text editor in a
full-fledged Unix environment is like the difference between crawling
and doing gymnastics.

By building on Vim's existing strengths as a text editor and interface
to the Unix operating system, SoyWiki makes it possible to create,
consult, and remold wiki content at the speed of thought. This is
SoyWiki's primary mission.

SoyWiki excels as a personal wiki. It is very good for tracking
projects, contacts, ideas, and collecting research. 

SoyWiki serves as a writing tool as well. It has an "expand-command"
that allows you to use wiki pages in a fashion essentially similar to
(and some might say more powerful than) an outline and generate an
"expanded-view" that bundles together several wiki pages into a single
long-form document.  SoyWiki makes it easy to take full advantage of a
large monitor and Vim's split windows, so you can have the research
material you've collected in SoyWik open in one or more windows and the
essay or paper you're drafting open in another. 

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

Will there even be a web browser interface to SoyWiki? Maybe. But the
main focus on SoyWiki is not on publishing a pretty website but on
making it easy to organize your thoughts and your knowledge.  Still, if
you want to publish any of the content in a SoyWiki wiki, it's easy to
write a program that will bundle up all the relevant wiki pages together
and convert them into a public-facing wiki website.

Finally, why CamelCase? There are many syntaxes for linking wiki pages
together. But CamelCase was the original, and it is still I think the
best.



## Prerequisites

* a recent version of Vim (SoyWiki is developed against Vim 7.2 and 7.3)
* a recent version of Ruby (SoyWiki is developed using Ruby 1.9.2)
* RubyGems (if Ruby version is older than 1.9)
* a recent version of git (at least 1.7.0.4)

The current version of SoyWiki assumes a Unix environment. 



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

You can use `<C-j>` or `,j` from either split window to show the next message.
You can use `<C-k>` or `,k` to show the previous message. 


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


