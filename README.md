ViB - Browser in Vi (Vim-Minimal)
=================================

Why should I use this browser?
------------------------------

Clocking in at 50 lines of python, this browser is easily extended and very minimal. The vi interface is reused to support a text based web browser: this means that it has vi keybindings by default. It has low memory usage owing to the reuse of the vi text editor as a web browser. It is portable to any operating system with python, vi, and curl installed, assuming that the python modules sys and html are present. The lack of support for images, video, and javascript can be considered features: this prevents mindless web surfing on social media while retaining the ability to search the web for useful information. Despite its name, vib can be used with many different text editors.

How to use
----------

Add the following functions to your ~/.bashrc file:

function get { 
	url="$(echo "$1" | cut -d' ' -f1)"
	data="$(echo "$1" | cut -d' ' -f2- -s)"
	curl --compressed -G -L -b /tmp/cookies -c /tmp/cookies -A [user_agent] https://"$url" -w '\n%{url_effective}' --data-urlencode "$data" --stderr - | sed -E 's/^[[:space:]]*|[^ -~]//g' | vib | sed '/^$/d';
}

function post { 
	url="$(echo "$1" | cut -d' ' -f1)"
	data="$(echo "$1" | cut -d' ' -f2- -s)"
	curl --compressed -L -b /tmp/cookies -c /tmp/cookies -A [user_agent] https://"$url" -w '\n%{url_effective}' --data-urlencode "$data" --stderr - | sed -E 's/^[[:space:]]*|[^ -~]//g' | vib | sed '/^$/d';
}

The names of the functions are arbitrary but will be used later in your .vimrc file. 

The get function performs a HTTP GET request. The post function performs a HTTP POST request. Each function can be extended and changed as necessary. The user agent is provided in each of the functions in the -A option because some websites do not work with curl's user agent. The cookie_file is provided in the -b and -c option if one wishes to maintain the state of an HTTP session. The --compressed option allows for faster requests and allows support for servers that send gzipped data regardless of the Accept: Encoding header. The --data-urlencode option is necessary to send data in GET and POST requests. The -L options is convenient because it enables curl to perform redirects. The --stderr option prevents curl from creating a blank line at the top of the file. Finally, the option -w is necessary for the python script to work: it assumes that the last url that curl requested is in the last line of the data. For more information about the options, read the curl manpage. 

The sed command 's/^[[:space:]]*|[^ -~]//g' in the function strips out any leading white space characters or characters that are not in the range from 32 to 126 inclusive: this allows for the removal of characters that do not display well in vim but may be changed to support UTF-8 characters. The command also serves to prevent link spoofing (see Warning). The command '/^$/d' deletes blank lines. For more information, read the sed manpage. 

Make sure the names of these functions do not collide with the names of any existing functions, aliases, or commands on your system.

Add the following mappings to your ~/.vimrc file with ^R entered as Ctrl-V+Ctrl-R:

map \b :%!bash -ic '
map \g yw:%!tail -n" \| bash -ic 'get "$(head -n1)"'<CR>
map \p yw:%!tail -n" \| bash -ic 'post "$(head -n1)"'<CR>
map \h :%!curl -L https://$(tail -n 1)<CR>

These mappings will not work by default in a text editor like nvi.

The \g and \p mapping should be used at the beginning of a link number (explained more below). The mappings \b and \h can be used at any location. The \g mapping is used for get requests. The \p mapping is used for post requests. The \b mapping is used for executing functions or aliases in the .bashrc file. The \h mapping is used to get the raw html of the site.

Links
-----
By default, the vib script will output lines at the bottom of a parsed webpage, looking like this:
www.google.com/search q=&btnK=Google Search&btnI=I'm Feeling Lucky&btnK=Google Search&btnI=I'm Feeling Lucky&source=hp&ei=tFWaYJ3WEYWB9u8P6dyt-A0&iflsig=AINFCbYAAAAAYJpjxKky4-qABenQlt4WPP5eMsQfMBKG

The first component is the HTTP endpoint. The second component is the data to be sent via GET/POST request. It is possible to edit or fill in this data and use it to make searches, login to websites, etc.

Link labels can be understood in the following way: ^[ Link Number ^] (HTTP Endpoint) (HTTP Request Type). 

^[5^] www.google.com/search GET

The last line of the file always corresponds to the current url of the webpage. This allows one to easily retrieve the raw html of the webpage by pressing \h. Links are written in reverse so that the first link is at the bottom of the page and the last link is above every other link.

Design Choices
--------------
The vib browser is designed to be as minimal as possible. This results in tremendous customizability. For example, since vi/vim does not support ANSI escape sequences for color, the octal sequence \033 and \035 are used to delimit a label for a url because these characters are blue in vim. With a different text editor like ed, it might be possible to use ANSI escape sequences. By default, the vib browser only supports http/https urls and does not handle urls of a different protocol correctly since this did not seem necessary for the majority of use cases. It is possible to add this functionality in the attr2url function. It also does not handle the majority of html elements such as \<option\>: this should added when the parser is rewritten using flex/yacc.

Basic Features
--------------
- Go Back/Go Forward in History - Press u to undo and Ctrl-r/u to redo
- Searching for text - Press / to search forwards and ? to search backwards
- Copy - Press y[action] to copy
- Delete cookie - Remove cookie in cookie file
- Request a URL - Press \b and type get [url]' followed by enter, where the url does not contain the protocol (https://)
- Click link - Search for \<link number\> and press \g at the beginning of the link number

For more features read the vi manpage.

Untested Features
-----------------
There is support for textarea elements, but this has yet to be tested. File upload is also supported via curl's -F option, but this is also untested.

Warnings
--------
When using --data-urlencode in curl, the @ symbol in GET or POST parameters may allow a malicious server to upload an arbitary file. This is mitigated by the presence of the = character in the python function handle_starttag.

In the vimrc mappings, it is necessary to prevent command injection from the url. Do not remove the quotes surrounding $(head -n 1), this is used to prevent the characters from being interpreted by the shell.

It may be possible for an attacker to try to inject the ^[ ^] characters to try to spoof a link. This is mitigated by the python script and sed utility which strip those characters from the html before presenting it to the user.
 
Other useful .bashrc functions
----------------------
function google { get "www.google.com/search q=$*"; }

function searx { post "searx.xyz/search q=$*"; }

Work In Progress
----------------
- Rewrite in flex/bison for portability and correctness

Bugs
----
Please send the website url and raw html to the email seL4@disroot.org, as well as any thing you have changed from the defaults.
