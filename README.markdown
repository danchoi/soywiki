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

SoyWiki is editor-centric. More than that, it's Vim-centric. The current
version of SoyWiki expects you to be fairly good at using Vim. More than
80 percent of the SoyWiki codebase implements the VimScript interface
layer.

While it forces you to learn Vim (which is a good thing to learn in any
case), SoyWiki requires you to learn only a tiny, nearly non-existent
markup language.  To make a piece of text work with SoyWiki, it just
needs to use CamelCase WikiWords.  Beyond that, you can mark up your
text any way you want, using Markdown, Texttile, AsciiDoc, or nothing.

But why Vim? And why CamelCase WikiWords? To answer these two questions
is to set forth SoyWiki's philosophy.

What is a wiki? In a gist, it's a respository of useful wisdom and
information should be easy and efficient to (1) navigate, (2) edit, and
(3) reorganize.  

Sounds simple, but what is easy for the beginner is often not efficient
for the proficient user. In fact it can feel downright backward and
barbaric.


Many wiki platforms compromise (1) (2) and (3) because they feature a
web-browser interface.  And they feature a web browser interface because
they want to make it as easy as possible




Its first priority is to make the process of creating, editing, and
refactoring wiki content as efficient and streamlined as possible.

It strives to be an unobtrusive as
possible requires WikiWords to be CamelCase 

[still editing]


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


