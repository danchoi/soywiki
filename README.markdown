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

SoyWiki builds on Vim's strengths as a text editor and interface to the
Unix operating system, SoyWiki makes it possible to create, navigate,
and refactor wiki content at the speed of thought. 

SoyWiki is good for tracking projects, contacts, ideas, and collecting
and organizing research. SoyWiki combines the affordances of notebooks,
index cards, and Post-it notes, and adds the power of hyperlinks and
automatic indexing.

SoyWiki makes a great writing aid, especially if you do your writing in
Vim. It takes full advantage of Vim's split windows. You can have
SoyWiki open in multiple Vim windows, and draft an essay or paper in
another.

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

Before you start SoyWiki, create a directory that will hold your wiki
files and `cd` into it. Then you can start SoyWiki with

    soywiki

You can make as many SoyWiki wikis on your system as you want just by
creating directories for them. It's not a good idea however to nest
SoyWiki wiki directories within each other, for reasons that will become
clear below.

## Basic Usage

For basic use, SoyWiki works exactly like a typical wiki.

You write text, and when you want to create a new wiki page, you come up
with a WikiWord for it and format it in CamelCase. The wiki-link you
just typed will automatically be syntax-highlighted, and pressing ENTER
on it will take you to the new page. Creating WikiWords and pressing
ENTER on them is the main way of linking wiki pages together. You'll be
surprised at how powerful this simple mechanism is for organizing your
notes. 

That's all you need to know to get started. 

## Power navigation 

Because SoyWiki is not just wiki but a Vim program, it lets you work a
lot faster and with a more economy than browser-based wikis. 

You can navigate a SoyWiki wiki very quickly with the following
commands. 

* `CTRL-n` and `CTRL-p` move the cursor directly to the next or previous wiki-link on the page
* `ENTER` follows the wiki-link under the cursor
* `,f` follows the first wiki-link after the cursor
* `,-` opens a wiki-link in a split window
* `,|` does the same, but in a vertical split window

You can also use Vim's jump motions `CTRL-o` and `CTRL-i` to move back
and forth in your jump history. See `:help jump-motions` for more on
this. You can press `CTRL-^` to toggle between the current page and the
last page you looked at.

You can view all the pages in your wiki, most recently modified first,
by press `,m`. This opens both a page list and autocompletion window.
You can use the standard Vim autocompletion commands here to find the
page you want and call it up.  See Vim's `:help ins-completion-menu` for
further instructions.

When you're on a wiki page and you want to see all the other wiki pages
that link in to it, press `,M`. If there is only one page that links in,
you'll be taken there automatically.

`,o` opens the first normal web hyperlink -- the ones that begin with http://
or https:// -- on or after the cursor in your default web browser.

Under the covers, SoyWiki uses the command `gnome-open` or `open` to
launch your web browser. This should cover Linux Gnome desktop and OS X
users. You can change the command SoyWiki uses to open a hyperlink by
adding this to your `~/.vimrc`:

    let g:SoyWiki#browser_command = "your browser command here"

If your Vim has `netrw`, you can open a hyperlink directly in same Vim
window by putting the cursor at the beginning of a hyperlink and typing
`gf`, or `C-w f` if you want to open the webpage in a split window.  See
`:help netrw` for more information.


## Power refactoring

SoyWiki makes it easy to reorganize your wiki with these commands.

You can rename a wiki page with`,r`. You'll see a prompt asking
you for the new name. Make sure it is valid CamelCase. After you press
ENTER, SoyWiki will rename the page and update all the links on other
pages in your wiki to be cognizant of the change.

You can delete a page with `,#`. 

TODO

Add append 


## Revision history and distributed workflows

SoyWiki delegates revision-tracking, syncing, and collaboration
workflows to Git.  SoyWiki automatically creates a git repository in
your wiki directory and automatically commits all the edits you make to
it.  You can sync a SoyWiki wiki between two computers using the
standard git push and pull commands.  Collaborators can also edit a
common wiki this way, in peer to peer fashion. 

SoyWiki provides a few convenient key mappings to view the revision
history of a wiki page: 

* `,l` shows the revision history of the current page
* `,b` shows a `git-blame` view of the current page, which shows when each line was added and by whom.
* `:SWLogStat` shows a `git log --stat` view of the current page's revision history

To sync your SoyWiki wiki between two personal computers, just follow
the general instructions [here][git-sync].

[git-sync]:http://www-cs-students.stanford.edu/~blynn/gitmagic/ch03.html




TO BE FINISHED


SoyWiki requires you to learn only a tiny, nearly
non-existent markup language.  To make a piece of text work with
SoyWiki, it just needs to use CamelCase WikiWords.  Beyond that, you can
mark up your text any way you want, using Markdown, Texttile, AsciiDoc,
or nothing.

## Opening hyperlinks and HTML parts in your web browser

