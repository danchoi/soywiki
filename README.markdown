# SoyWiki

SoyWiki is lightweight application that turns Vim into a fast and
powerful wiki. 

A quick overview of its characteristics and features:

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
* outliner-like capability with expansion commands
* operates on all POSIX systems (e.g. OS X, Linux, FreeBSD)

SoyWiki builds on Vim's strengths as a text editor and interface to the
Unix operating system, SoyWiki makes it possible to create, navigate,
and refactor wiki content at the speed of thought. 

SoyWiki is good for tracking projects, contacts, ideas, and collecting
and organizing research. SoyWiki combines the affordances of notebooks,
index cards, and Post-it notes, and adds the power of hyperlinks and
automatic indexing.

SoyWiki makes a great writing aid, especially if you do your writing in
Vim. You can have SoyWiki open in multiple Vim windows, tabs, and
buffers, and open even more windows and tabs alongside them for editing
an essay, chapter, or paper. Throw a bunch of Vim abbreviations (`:help
abbreviations`), a large monitor, and a teapot, and you'll have your
paper, essay, book, or screenplay written faster, sooner, and better.

You don't need to shell out $$ for tools like [Scrivener][scriv] if
you appreciate how much more powerful Vim is for editing and navigating
text and how liberating it is to be able to store your content in the
non-proprietary, universal plain-text format. Proprietary tools like
Scrivener will come and go every few years, but the plain text file
format and Vim are forever.

SoyWiki is free and open source.

[scriv]:http://www.literatureandlatte.com/scrivener.php

## Prerequisites

* a recent version of Vim (SoyWiki is developed against Vim 7.2 and 7.3)
* a recent version of Ruby (SoyWiki is developed using Ruby 1.9.2)
* RubyGems (if Ruby version is older than 1.9)
* a recent version of Git (1.7.0.4 or above to be safe)

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

New and improved versions of SoyWiki will be released over time. To install the
latest version, just type `gem install soywiki` again.


## Starting SoyWiki

Before you start SoyWiki, create a directory that will hold your wiki
files and `cd` into it. Then you can start SoyWiki with

    soywiki

You can make as many SoyWiki wikis on your system as you want just by
creating directories for them. It's not a good idea however to nest
SoyWiki wiki directories within each other, for reasons that will become
clear below.

To use MacVim as your SoyWiki Vim engine, you can run soywiki like this

    SOYWIKI_VIM=mvim soywiki

or you can `export SOYWIKI_VIM=mvim` in your `~/.bash_profile` and then
just run `soywiki`.

## Basic usage

For basic use, SoyWiki works exactly like a typical wiki.

You write text, and when you want to create a new wiki page, you come up
with a WikiWord for it and format it in CamelCase. The wiki-link you
just typed will automatically be syntax-highlighted, and pressing ENTER
on it will take you to the new page. Creating WikiWords and pressing
ENTER on them is the main way of linking wiki pages together. You'll be
surprised at how powerful this simple mechanism is for organizing your
notes. 

That's all you need to know to get started. 

## Wiki navigation 

Because SoyWiki is not just wiki but a Vim program, it lets you work a
lot faster and with more economy than browser-based wikis. 

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

## Wiki-link autocompletion

When you're writing a wiki page and you want to link to another page,
SoyWiki can help you autocomplete your wiki-link. Press `CTRL-x CTRL-u`
in Vim insert mode to invoke it.


## Wiki refactoring

You can rename a wiki page with`,r`. You'll see a prompt asking
you for the new name. Make sure it is valid CamelCase. After you press
ENTER, SoyWiki will rename the page and update all the links on other
pages in your wiki that need updating because of the change.

You can delete a page with `,#`. 

Beyond the standard cut and paste, SoyWiki gives you four fast ways of
shuttling text from one wiki page to another.

First, highlight the text you want to move with Vim's visual mode. (See
`:help visual-mode` for more info) 

Then, type

* `:SWInsert [target]` to move the text to the top of target page
* `:SWAppend [target]` to move the text to the bottom of the target page
* `:SWLinkInsert [target]` performs `:SWInsert` and replaces the text with a WikiWord link
* `:SWLinkAppend [target]` performs `:SWAppend` and replaces the text with a WikiWord link

`[target]` is the name of the file that contains the wiki page you're
targeting. Press `TAB` for autocompletion help.

These commands will open the target page (if it isn't open already) in a
split window and insert or append the selected text into it.  If the
target page doesn't exist, it will be created.

You can use these shortcuts:

* `:SWInsert` &rarr; `:SWI`
* `:SWAppend` &rarr; `:SWA`

With `:SWLinkInsert` and `:SWLinkAppend` you can use tab-autocompletion
to avoid typing out the whole command name.


## Search

To search your SoyWiki wiki, type `:SWSearch [search term]`. Vim will
load any matches in the quickfix list window.  If there are matches, you
can use `:cn` and `:cp` to go from match to match.  See `:help quickfix`
for more QuickFix commands. 

Searches are case-insensitve by default. To do a case-sensitive search,
add a `\C` to your search string, e.g.:

    :SWSearch Gnu\C

Again, you can use `:SWS` as a shortcut.

Under the hood, `:SWSearch` is just a thin wrapper around the `:vimgrep`
command.


## Revision history and distributed workflows

SoyWiki delegates revision-tracking, syncing, and collaboration
workflows to Git.  SoyWiki automatically creates a Git repository in
your wiki directory and automatically commits all the edits you make to
it.  You can sync a SoyWiki wiki between two computers using the
standard Git push and pull commands.  Collaborators can also edit a
common wiki this way, in peer to peer fashion. 

SoyWiki provides a few convenient key mappings to view the revision
history of a wiki page: 

* `,l` shows a `git-log` view of the revision history of the current page
* `,b` shows a `git-blame` view of the current page, which shows when each line was added and by whom.
* `:SWLogStat` shows a `git log --stat` view of the current page's revision history

You can always bypass Vim and SoyWiki altogether and use Git directly to
inspect your revision history. The Git repo for your SoyWiki wiki will
be located in the same directory as your wiki files.

To sync your SoyWiki wiki between two personal computers, just follow
the general instructions [here][git-sync].

[git-sync]:http://www-cs-students.stanford.edu/~blynn/gitmagic/ch03.html


## Namespaced WikiWords

You can get very far with SoyWiki using normal CamelCase WikiWords.  

    NormalWikiWord

But if you want, you can also namespace your WikiWords, like so:

    namespaced.WikiWord

A namespaced WikiWord is a WikiWord prefixed by a namespace. The
namespace word must start with a lower-case letter and consist 
only of letters, numbers, and underscore characters. You can't chain
namespace words together: the maximum nesting level is 1.

Namespaced WikiWords help organize your conceptual wiki space. They also
have two other benefits: 

First, wiki pages that represent a namespaced WikiWord are stored under a
subdirectory named after the namespace. This can help reduce the clutter in
your wiki directory.

Second, a WikiWord namespace lets you use abbreviated links within that
namespace. For example, if you are editing a page called
`recipes.SoyMacaroni` and you want to link to another page in the same
namespace called `recipes.SoyRaspberrySmoothie` you can type the link in
this special abbreviated form:

    .SoyRaspberrySmoothie

SoyWiki will know from the leading period that this is a link to another
page in the same namespace. 

WikiLink autocompletion also works with abbreviated namespaced links. Just type a
period, and invoke autocompletion with `CTRL-x CTRL-u`.


## Expanding a Wiki page

SoyWiki lets you render a wiki page in "expanded" form.  What this does
is expand all the wiki links on the page that appear alone on a line to
include their content inline. This works recursively in all the included
wiki pages (though it does not go into vicious circles because it only
expands each link once).

The rendered page appears in a Vim scratch buffer. From there you can
write it out to a new text file, pipe it to `lpr` to print it, or
whatever you like. 

There are two forms of expansion: seamful and seamless. Seamful
expansion expands wiki links into wiki pages and clearly marks where
this has happened by including markers along with the WikiWord that was
expanded. Seamless expansion does not mark a point of expansion with
anything, and it erases the WikiWord that got expanded. 

* `,x` expands a wiki page seamfully
* `,X` expands a wiki page seamlessly

Both modes of expansion are useful when you want to assemble a long
piece of writing by using one page as a master outline and linking from
this to other wiki pages that include the real content. And since
expansion is recursive, you can effectively nest outlines within
outlines, like dreams within dreams.  


## Why CamelCase WikiLinks rule

Some people don't like the CamelCase (a.k.a. WikiCase) wiki link
pattern. But SoyWiki embraces it and wants everyone to adopt it, for the
following reasons:

* Besides being the original, CamelCase is the most elegantly minimalist approach to linking wiki pages together -- "with no additional markup whatsoever," as [Ward Cunningham put it][ward]. 
* It encourages you more than other wiki link patterns to create wiki pages with succinctly descriptive names.  
* Because the link pattern is so minimal and succinct, inserting them in
your notes interrupts your flow of
thought a lot less than other wiki patterns.
* It is very conducive to storing
wiki pages in plain text files: the page names can map directly to Unix
file names without any awkward character escaping.

[ward]:http://c2.com/cgi/wiki?WikiCase


## Why name a wiki engine after a legume?

I am a fan of food made of [soy][soylink]: soy ice cream, soy milk, soy
burgers, soy butter, you name it. The word "soy" has come to signify a
newer, lighter, healthier alternative to the same old same old. SoyWiki
may not be an actual soy product, but it tries to be a wiki engine with
soy-like benefits.

[soylink]:http://www.mayoclinic.com/health/soy/NS_patient-soy

## How to contact the developer

My name is Daniel Choi. I am based in Cambridge, Massachusetts, USA, and you
can email me at dhchoi {at} gmail.com.  

## How to support the SoyWiki project

If you find SoyWiki very useful, feel free to drop me a note to say so. If you
have a bug to report or a good feature to suggest, please file it on the [issue
tracker][1].  

[1]:https://github.com/danchoi/soywiki/issues


