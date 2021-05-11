ViB - Browser in Vi (Vim-Minimal)
=================================

Why should I use this browser?
------------------------------

Clocking in at 50 lines of python, this browser is easily extended and is highly unlikely to have serious security vulnerabilities (excluding curl). The vi interface is reused to support a text based web browser: this means that it has vi keybindings by default. It has minimal memory usage owing to the reuse of the vi text editor as a web browser. It is portable to any operating system with python, vi, and curl installed, assuming that the python modules sys and html are present. The lack of support for images, video, and javascript can be considered features: this prevents mindless web surfing on social media while retaining the ability to search the web for useful information. Despite its name vib can be used with many different text editors.

How to use
----------

Add the following functions to your ~/.bashrc file:

function get { curl -A [user_agent] -b [cookie_file] -c [cookie_file] --compressed --data-urlencode "$2" -G -L -w '\n%{url_effective} https://"$1" | /path/to/vib | sed 's/^\s*\|[^-~]//g; /^$/d'; }

function html { curl -A [user_agent] -b [cookie_file] -c [cookie_file] --compressed --data-urlencode "$2" -G -i -v -w '\n%{url_effective} https://"$1"; }

function post { curl -A [user_agent] -b [cookie_file] -c [cookie_file] --compressed -L https://"$1" --data-urlencode "$2" -w '\n%{url_effective}' | /path/to/vib | sed 's/^\s*\|[^-~]//g; /^$/d'; }

The names of the functions are arbitrary but will be used later in your .vimrc file. 

The get function performs a HTTP GET request. The html function performs a HTTP GET request but does not parse the html. The post function performs a HTTP POST request. Each function can be extended and changed as necessary. The user agent is provided in each of the functions in the -A option because some websites do not work with curl's user agent. The cookie_file is provided in the -b and -c option if one wishes to maintain the state of an HTTP session. The --compressed option allows for faster requests and allows support for servers that send gzipped data regardless of the Accept: Encoding header. The --data-urlencode option is necessary to send data in GET and POST requests. The -L options is convenient because it enables curl to perform redirects. Finally, the option -w is necessary for the python script to work: it assumes that the last url that curl requested is in the last line of the data. For more information about the options, read the curl manpage. 

The sed command 's/\^s*/\|[^-~]//g' in the function strips out any leading white space characters or characters that are not in the range from 27 to 126 inclusive: this allows for the removal of characters that do not display well in vim but may be changed to support UTF-8 characters. The sed command '/^$/d' deletes blank lines in the formatted output of the vib command. For more information, read the sed manpage. 

Make sure the names of these functions do not collide with the names of any existing functions, aliases, or commands on your system.

Add the following mappings to your ~/.vimrc file:

map \e :s/[%#&]/\\&/g<CR>
map \g f ly$:%!bash -ic "get ""<CR>
map \p y$:%!bash -ic "post ""<CR>
map \h y$:%!bash -ic "html ""<CR>
map \b :%!bash -ic "

These mappings will not work by default in a text editor like nvi.

The \e mapping allows for escaping characters that are interpreted in vim. The \g mapping should be used at the beginning of a url line (explained more below). For example, in the url line

<0> lobste.rs/

, the cursor should be placed before the '<' character before executing the mapping. For mappings \p and \h, the mapping should be used at the beginning of any url, but will usually be used for url lines. The mapping \b can be used at any location.

The \g mapping is used for get requests. The \p mapping is used for post requests. The \h mapping is used to read the html of a website. The \b mapping is used for executing functions or aliases in the .bashrc file.

URL Lines
---------
By default, the vib script will output lines at the bottom of a parsed webpage, looking like this:
<168> news.ycombinator.com/user?id=fm77

The <[0-9]+> component is the label of the url, which enables one to easily search for a link. It corresponds to a similar label in the webpage that looks like: 
168 fm77

The <0> label always corresponds to the current url of the webpage. This allows one to easily retrieve the raw html of the webpage by using the \h mapping.

Link Labels
------
5GET www.google.com/search

Label can be understood in the following way: 
Delimiter Number (HTTP Request Type) Delimiter (HTTP Endpoint)

Design Choices
--------------
The vib browser is designed to be as minimal as possible. This results in many inelegant hacks and missing features that can be added by the user. For example, since vi/vim does not support ANSI escape sequences for color, the octal sequence \033 and \035 are used to delimit a label for a url because these characters are blue in vim. With a different text editor like ed, it might be possible to use ANSI escape sequences. By default, the vib browser only supports http/https urls and does not handle urls of a different protocol correctly since this did not seem necessary for the majority of use cases. It is possible to add this functionality in the attr2url function. It also does not handle the majority of html elements such as <option>: this should be added manually by the user.

Basic Features
--------------
Go Back/Go Forward in History - Press u to undo and Ctrl-r/u to redo
Searching for text - Press / to search forwards and ? to search backwards
Copy - Press y[action] to copy
Delete cookie - Remove cookie in cookie file
Request a URL - Press \b and type get [url]" followed by enter
Click link - Search for <link number> and press \u

For more features read the vi manpage.

Untested Features
-----------------
There is support for textarea elements, but this has yet to be tested. File upload is also supported via curl's -F option, but this is also untested.
 
Other useful functions
----------------------
function google { get www.google.com/search "q=$*"; }
function searx { post searx.xyz/search "q=$*"; }

Work In Progress
----------------
- Rewrite in flex/bison for portability and correctness
- Add better support for option elements
- Add limited support for javascript
