# SoyWiki

SoyWiki turns Vim into a powerful, lean, and fast wiki.  It's got all the
protein of a more conventional wiki, but less saturated fat and no
cholesterol. 

[screenshots]

A quick overview of SoyWiki's characteristics and features:

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
* can open web hyperlinks in external browser or inside Vim
* outliner-like capability with expansion commands
* operates on all POSIX systems (e.g. OS X, Linux, FreeBSD)

SoyWiki builds on Vim's strengths as a text editor and interface to the
Unix operating system, SoyWiki's primary goal is to make it possible to
create, navigate, and refactor wiki content at the speed of thought. 

SoyWiki is good for tracking projects, contacts, ideas, and collecting
and organizing research. SoyWiki combines the affordances of notebooks,
index cards, and Post-it notes, and adds to them the power of
hyperlinks, search, revision history, automated refactoring, and more.

SoyWiki makes a good writing aid, especially if you do your writing in
Vim. You can have SoyWiki open in multiple Vim windows, tabs, and
buffers, alongside any number of regular Vim windows. Throw in a bunch
of Vim abbreviations (`:help abbreviations`), a large monitor, and a
teapot, and you'll have a powerful toolkit for writing your paper, essay,
book, or screenplay. 

SoyWiki is free and open source.

[scriv]:http://www.literatureandlatte.com/scrivener.php

## Prerequisites

* a recent version of Vim (SoyWiki is developed against Vim 7.2 and 7.3)
* a recent version of Ruby: Ruby 1.9.2 is recommended
* RubyGems (if Ruby version is older than 1.9)
* a recent version of [Git][git] (1.7.0.4 or above to be safe)

[git]:http://git-scm.com/

The current version of SoyWiki assumes a Unix environment. 

To use SoyWiki you should be fairly good at using Vim. 

To install Ruby 1.9.2, I recommend using the [RVM Version Manager][rvm].

[rvm]:http://rvm.beginrescueend.com

Most of SoyWiki's commands should work even if you don't have Git
installed. But the revision history commands will not.

## Installation

    gem install soywiki

Test your installation by typing `soywiki -h`. You should see SoyWiki's help.

If you run into any PATH errors, try the following: Install the RVM
Version Manager, then install Ruby 1.9.2 through RVM, and then run `gem
install soywiki`.  This should solve any installation issues.

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


You can start SoyWiki from within a running Vim session. To set this up,
first install or update SoyWiki, and then run

    soywiki --install-plugin

Please note that you will need to run this command after each time you update
SoyWiki to a newer version.

Assuming the plugin is installed, you can start SoyWiki from within a
running Vim session by typing the command

    :Soywiki

Make sure when you do this that Vim's working directory is the root of
your wiki directory. You can change the working directory for the 
current Vim window with `:lcd`. See `:help lcd` for more info.


## Basic usage

For basic use, SoyWiki works exactly like a typical wiki.

You write text, and when you want to create a new wiki page, you come up with a
WikiWord for it and format it in CamelCase. Whenever you type a valid WikiLink,
it will automatically be syntax-highlighted, and pressing ENTER on it will take
you to the new page. 

Creating WikiWords and pressing ENTER on them is how you create wiki pages and
link them together. You'll be surprised at how powerful this simple mechanism
is for organizing your notes. 

In SoyWiki, a wiki page is a simple text file that has a WikiWord title
on the first line. Beyond that, you can append any text you want.  (You
may alter the title line at the top, but it helps you see what wiki page
you're on.) SoyWiki will create stub WikiPages for you automatically as
you traverse WikiLinks that don't yet reference any content.

That's all you need to know to get started. 

## Namespaced WikiWords

Every WikiWord in SoyWiki is implicitly or explicitly namespaced.
SoyWiki's namespaced WikiWords help organize your wiki space
conceptually.  They also help reduce clutter in your wiki directory.

An explicitly namespaced WikiWord looks like this:

    recipes.SoyRaspberrySmoothie

The implicitly namespaced form looks just like a conventional WikiWord:

    SoyRaspberrySmoothie

A namespace must start with a lower-case letter and consist only of letters,
numbers, and underscore characters. 

Within a WikiWord namespace you can use unqualified WikiWords to link
pages within that namespace together. For example, if you are editing a
page called `recipes.SoyMacaroni` and you want to link to a page called
`recipes.SoyRaspberrySmoothie`, you can type a link called
`SoyRaspberrySmoothie`. SoyWiki will treat this link as an implicitly
namespaced link to another page in the `recipes` namespace. 

SoyWiki wiki pages are stored as text files named by WikiWord within
subdirectories named after their namespace. So
`recipes.SoyRaspberrySmoothie` would be written to
`recipes/SoyRaspberrySmoothie`.

You can't chain namespace words together. The maximum nesting level is 1.  More
nesting would imply hierarchical relationships, and permitting hierarchical
nesting goes against the grain of what a wiki is, which is an [undirected
graph][graph].  SoyWiki namespaces are not supposed to represent hierarchies,
but domains (e.g., personal, work, project1, project2, etc.).  You can easily
represent hierarchical relationships _within_ a wiki page. See "Expanding a
wiki page" below to see how you can use SoyWiki like an outliner program.

[graph]:http://en.wikipedia.org/wiki/Graph_theory


When you start SoyWiki for the first time, the active namespace is the default
namespace `main`. `main.HomePage` is the first page you will see.

## Wiki navigation 

You can navigate a SoyWiki wiki very quickly with the following
commands: 

* `CTRL-j` and `CTRL-k` move the cursor directly to the next or previous WikiLink on the page
* `ENTER` follows the WikiLink under the cursor
* `,f` follows the first WikiLink after the cursor
* `CTRL-l` opens a WikiLink in a vertical split window; press `CTRL-l` again
while the cursor is on the top line to close the new window 
* `CTRL-h` does the same, but in a regular split window
* `q` closes a split window 
* `,h` takes you to the `HomePage` of the current namespace
* `,H` takes you to `main.HomePage` 

These key mappings may not be very mnemonic, but they are easy to
memorize through muscle memory and were chosen to keep the hands
stationary and the fingers near home position on a QWERTY keyboard while
navigating the wiki.

You can also use Vim's jump motions `CTRL-o` and `CTRL-i` to move back
and forth in your jump history. See `:help jump-motions` for more on
this. You can press `CTRL-^` to toggle between the current page and the
last page you looked at.

* `,m` opens the page list
* `,n` opens the namespace list
* `,M` opens the inbound links page list 

You can view all the pages in your wiki, most recently modified first,
by pressing `,m`. This opens both a page list and autocompletion window.
You can use the standard Vim autocompletion commands here to find the
page you want and call it up.  See Vim's `:help ins-completion-menu` for
further instructions.

When you're on a wiki page and you want to see all the other wiki pages
that link in to it, press `,M`. If there is only one page that links in,
you'll be taken there automatically.

`,n` lets you select from your namespaces. Choosing one will take you to
the `HomePage` of that namespace.


## Opening web hyperlinks

* `,o` opens the first web hyperlink under or after the cursor in the default external web browser
* `ENTER` opens the web hyperlink under the cursor in the default external web browser
* `,O` opens the web hyperlink under the cursor in a vertical split window
* `CTRL-w f` opens the web hyperlink under the cursor in a normal split window 
* `gf` opens the web hyperlink under the cursor in the same Vim window

`,o` opens the next web hyperlink on or after the cursor in your default
external web browser. Web hyperlinks  are the URLs that begin with
http:// or https://. You can also use `ENTER` when the cursor is over a
web hyperlink.

Under the covers, SoyWiki uses the command `gnome-open` or `open` to
launch your external web browser. This should cover Linux Gnome desktop
and OS X users. You can change the command SoyWiki uses to open a
hyperlink by adding this to your `~/.vimrc`:

    let g:SoyWiki#browser_command = "your browser command here"

If your Vim has `netrw` installed, you can open a hyperlink directly in
Vim by putting the cursor on a web hyperlink and typing `gf`, `CTRL-W f`
or `,O` (capital O). All these commands open the webpage inside your Vim
session using `elinks` or whatever browser you set as your
`g:netrw_http_cmd`.  See `:help netrw` for more information.

TIP: I personally prefer using `netrw` (configured to use elinks) to
launching URLs in an external web browser. This lets me keep all my URL
bookmarks in regular text files and open, clip, and annotate them all in
SoyWiki and Vim. Using `netrw` helps your text editor rather than your
web browser dominate your workflow.  And you tend to stay focused on
your task rather than going down the rabbit hole of internet
distractions.


## WikiLink autocompletion

When you're writing a wiki page and you want to link to another page,
SoyWiki can help you autocomplete your WikiLink. Press `CTRL-x CTRL-u`
in Vim insert mode to invoke it.


## Wiki refactoring

You can delete the current page with `:SWDelete`.

`:SWRenameTo [new name]` renames the current page. Make sure the new name
is valid CamelCase. You can put a namespace in front of the new name
as `namespace.` or `namespace/`. If you omit the namespace, the current
namespace is assumed.

When you rename a page, SoyWiki will update all the links on other pages
in your wiki that need to be updated in light of the change. (You'll see
the other links that were updated in the output.)

To create a wiki page directly, without first typing a WikiWord and
traversing it, type `:SWCreate` followed by the full path to the new
page. The form of the argument here should be `namespace/WikiWord`. You
may use command line file path autocomplete to fill out the namespace
subdirectory if it already exists.

TIP: I recommend not using :SWCreate to create wiki pages. Prefer the
method of writing a WikiLink and then traversing it. This will make your
wiki more interlinked, better organized, and easier to traverse in an
organic way.

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
targeting, e.g. `recipes/SoyRaspberrySmoothie`. Press `TAB` for
autocompletion help.

These four commands will open the target page (if it isn't open already)
in a split window and insert or append the selected text into it.  If
the target page doesn't exist, it will be created.

You can use these shortcuts:

* `:SWDelete` &rarr; `:SWD`
* `:SWRename` &rarr; `:SWR`
* `:SWCreate` &rarr; `:SWC`
* `:SWInsert` &rarr; `:SWI`
* `:SWAppend` &rarr; `:SWA`

With `:SWLinkInsert` and `:SWLinkAppend` you can use Vim's command line
completion (`:help cmdline-completion`) to avoid typing out the whole command name.

Also, you can use Vim's command line history (`:help cmdline-history`)
and command line window (`:help cmdline-window`) to save keystrokes when
you want to repeatedly execute an insert or append command targeting the
same wiki page.


## Search

* `:SWSearch [term]`
* `:SWNamespaceSearch [term]`

These commands search your SoyWiki wiki. `:SWNamespaceSearch` confines
your search to the current namespace.

Vim will load any matches in the quickfix list window.  If there are
matches, you can use `:cn` and `:cp` to go from match to match, `:cl` to
list the matches, and `:cc [item number]` to see a particular match ln
the list.  See `:help quickfix` to see the list of matches. for more
QuickFix commands. 

Examples:

    :SWSearch gnu
    :SWNamespaceSearch gnu

You can use `:SWS` as a shortcut for `:SWSearch`. You can also
tab-complete `:SWN` to `:SWNamespaceSearch`.

Searches are case-insensitve.  

Under the hood, `:SWSearch` is just a thin wrapper around the `:vimgrep`
command. Use `:vimgrep` directly if you want to do anything more
specific.

TIP: You can flag important notes in your wiki content by typing flags
like TODO or IMPORTANT! on the same line, and then use `:SWSearch` and
`:cl` to see all instances of them across your entire wiki.

## Revision history and distributed workflows

SoyWiki delegates revision-tracking, syncing, and collaboration
workflows to Git.  SoyWiki automatically creates a Git repository in
your wiki directory and automatically commits all the edits you make to
it.  You can sync a SoyWiki wiki between two computers using the
standard Git push and pull commands.  Collaborators can also edit a
common wiki this way, in peer to peer fashion. 

SoyWiki provides a few convenient key mappings to view the revision
history of a wiki page: 

* `,lp` shows a `git-log -p` view of the revision history of the current page
* `,ls` shows a `git log --stat` view of the current page's revision history
* `,b` shows a `git-blame` view of the current page, which shows when each line was added and by whom.

You can always bypass Vim and SoyWiki altogether and use Git directly to
inspect your revision history. The Git repo for your SoyWiki wiki will
be located in the same directory as your wiki files.

To sync your SoyWiki wiki between two personal computers, you can follow
the instructions [here][git-sync] and set up an bare Git repository on
some server for all your computers to push to and pull from.

[git-sync]:http://www-cs-students.stanford.edu/~blynn/gitmagic/ch03.html

If you want something simpler, you could also try keeping your wiki
folder in a [Dropbox][dropbox] folder.

[dropbox]:http://stevelosh.com/projects/t/#it-does-the-simplest-thing-that-could-possibly-work

If you want to edit a common SoyWiki with many other people, it's
probably best to set up a common upstream Git repository (e.g. on
GitHub, if the wiki content is for public consumption).  This process
may be intimidating for non-programmers, so a future version of SoyWiki
may provide a more user-friendly interface for distributed collaboration
workflows.



## Expanding a wiki page

SoyWiki lets you "expand" a wiki page.  What this does is expand all the
wiki links in the page that appear alone on a line.  Each of these links
is replaced by the content of the wiki page the link points to. This
expansion works recursively on all the expanded content.  Don't worry.
It can't fall into an infinite recursive loop because it will only
expand each WikiWord it encounters once, leaving all subsequent
references to the same WikiWord unexpanded.

The expanded version of the page will appear in a new Vim scratch buffer.
From there you can write it out to a new text file, pipe it to `lpr` to
print it, or whatever you like. 

There are two forms of expansion: seamful and seamless. Seamful
expansion expands wiki links into wiki pages and clearly marks where
this has happened by including markers along with the WikiWord that was
expanded. Seamless expansion does not mark a point of expansion with
anything, and it erases the WikiWord that got expanded. 

* `,x` expands a wiki page seamfully and opens on a vertical split
* `,X` expands a wiki page seamlessly and opens on a vertical split
* `,xx` expands a wiki page seamfully and opens on normal split
* `,XX` expands a wiki page seamlessly and opens on a normal split
* `q` closes the expanded view window

Both modes of expansion are useful when you want to assemble a long
piece of writing by using one page as a master outline that links to
other wiki pages that include the real content. And since expansion is
recursive, you can effectively nest outlines within outlines, like
dreams within dreams.  


## Exporting to HTML

* `soywiki --html` 

Want to share your wiki with non-Vim-users?  You can export your wiki
into a directory of HTML pages. Type `soywiki --html` from the root
directory of your wiki.

Aside from WikiWords, SoyWiki uses no markup system whatsoever. You can
write your content in whatever markup system you want, or no markup
system at all. It's all plain text to SoyWiki.  The HTML export feature
just wraps your content in &lt;pre&gt; tags after turning your WikiWords
into hyperlinks, so no markup system is really necessary.

HTML export is no-frills and basic. Hopefully, someday, SoyWiki will be
able to

* sport an alternative web interface that is as cool as [TiddlyWiki's][tiddly] and [GTDTiddlyWiki's][gtd] 
* let you specify a markup system for rendering the HTML version of your content
* come bundled with a Sinatra application that translates wiki pages into web pages upon request

[tiddly]:http://www.tiddlywiki.com/
[gtd]:http://nathanbowers.com/gtdtw/

If you want to contribute any of these features, please feel free to implement
them and submit a pull request.


## Extra macros

SoyWiki adds a few convenient Vim macros. 

* `\` in normal mode reformats the current paragraph. It is equivalent to
`gqap`. (`:help formatting`)
* `,-` inserts a long dashed line
* `,d` inserts the current date and time 
* `,D` inserts a long dashed line, followed by the current date and time 
 

## Getting help

Typing `,?` will open the help webpage in a browser.


## CamelCase WikiLinks rule!

Some people don't like the CamelCase (a.k.a. WikiCase) wiki link
pattern. But SoyWiki stands with CamelCase. 

* Besides being the original, CamelCase is the most elegantly minimalist approach to linking wiki pages together -- "with no additional markup whatsoever," [as Ward Cunningham put it][ward]. 
* It encourages you more than other wiki link patterns to create wiki pages with succinctly descriptive names that are easy to remember.
* Because the link pattern is so minimal and succinct, writing wiki links interrupts your flow of thought less than other wiki link patterns.
* CamelCase wiki links are less noisy than other link patterns in raw plain text form. This also contributes to flow.
* The CamelCase link pattern is very conducive to storing wiki pages in plain text files: the page names can map directly to Unix file names without any awkward character escaping or munging.

[ward]:http://c2.com/cgi/wiki?WikiCase

No wiki link pattern is perfect! All involve trade-offs. The CamelCase
pattern gives you a lot in return for its particular compromises. 


## Bug reports and feature requests

SoyWiki is very new, so there are kinks and bugs to iron out and lot of
desirable features to add.  If you have a bug to report or a good feature to
suggest, please file it on the [issue tracker][1].  That will help a lot.

[1]:https://github.com/danchoi/soywiki/issues

You can also join the [Google Group][group] and comment there.

[group]:http://groups.google.com/group/soywiki-users?msg=new&lnk=gcis

## How to contact the developer

My name is Daniel Choi. I am based in Cambridge, Massachusetts, USA, and you
can email me at dhchoi {at} gmail.com.  


