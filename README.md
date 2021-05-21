ViB - Browser in Vi (Vim-Minimal)
=================================

Why should I use this browser?
------------------------------

Clocking in at 46 lines of executable code, this browser is easily extended and very minimal. The vi interface is reused to support a text based web browser: this means that it has vi keybindings by default. It is portable to any operating system with python3, vi, and curl installed. The lack of support for images, video, and javascript can be considered features: this prevents mindless web surfing on social media while retaining the ability to search the web for useful information. Despite its name, vib can be used with many different text editors.

How to use
----------

Add the following functions to your ~/.bashrc file:

	function get { 

		url="$(echo "$1" | cut -d' ' -f1)"

		data="$(echo -n "$1" | cut -d' ' -f2- -s)"

		curl --compressed -G -L -b /tmp/c -c /tmp/c -A 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0' "$url" -w '\n%{url_effective}' --data-raw "$data" 2>&1 | vib | sed -E 's/^[[:space:]]*|[^^[-~]//g; /^$/d';

	}

	function post { 

		url="$(echo "$1" | cut -d' ' -f1)"

		data="$(echo -n "$1" | cut -d' ' -f2- -s)"

		curl --compressed -L -b /tmp/c -c /tmp/c -A 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0' "$url" -w '\n%{url_effective}' --data-raw "$data" 2>&1 | vib | sed -E 's/^[[:space:]]*|[^^[-~]//g; /^$/d';

	}

The names of the functions are arbitrary but will be used later in your .vimrc file. 

The get function performs a HTTP GET request. The post function performs a HTTP POST request. Each function can be extended and changed as necessary. The user agent is provided in each of the functions in the -A option because some websites do not work with curl's user agent. The cookie_file is provided in the -b and -c option if one wishes to maintain the state of an HTTP session. The --compressed option allows for faster requests and allows support for servers that send gzipped data regardless of the Accept: Encoding header. The --data-raw option is necessary to send data in GET and POST requests. The -L options is convenient because it enables curl to perform redirects. The 2>&1 argument prevents curl from creating a blank line at the top of the file. Finally, the option -w is necessary for the python script to work: it assumes that the last url that curl requested is in the last line of the data. For more information about the options, read the curl manpage. 

The sed command `s/^[[:space:]]*|[^^[-~]//g` in the function strips out any leading white space characters or characters that are not in the range from 27 to 126 inclusive: this allows for the removal of characters that do not display well in vim but may be changed to support UTF-8 characters. The command `/^$/d` deletes blank lines. For more information, read the sed manpage. 

Make sure the names of these functions do not collide with the names of any existing functions, aliases, or commands on your system.

Add the following mappings to your ~/.vimrc file with ^R entered as Ctrl-V+Ctrl-R:

	map \b :%!bash -ic '

	map \u :%!bash -ic 'get https://

	map \g yw:%!tail -n^R" \| bash -ic 'get "$(head -n1)"'<CR>

	map \p yw:%!tail -n^R" \| bash -ic 'post "$(head -n1)"'<CR>

	map \h :%!curl -b [cookie_file] -c [cookie_file] -L "$(tail -n 1)"<CR>

	map \f ywG:$-^R"<CR>j

These mappings will not work by default in a text editor like nvi.

The \g, \p, and \f mapping should be used at the beginning of a link number (explained more below). The mappings \u, \b, and \h can be used at any location. The \g mapping is used for get requests. The \p mapping is used for post requests. The \f mapping is used to find the link corresponding to a link numer. The \b mapping is used for executing functions or aliases in the .bashrc file. The \h mapping is used to get the raw html of the site. The \u mapping is used for requesting urls.

Links
-----
By default, the vib script will output lines at the bottom of a parsed webpage, looking like this:

https://lwn.net/Login/newaccount submit=Register

The first component is the HTTP endpoint. The second component is the data to be sent via GET/POST request. It is possible to edit or fill in this data and use it to make searches, login to websites, etc.

Link labels can be understood in the following way: ^[ Link Number ^] (HTTP Endpoint) (HTTP Request Type). 

^[5^] www.google.com/search get

The last line of the file always corresponds to the current url of the webpage. This allows one to easily retrieve the raw html of the webpage by pressing \h. Links are written in reverse so that the first link is at the bottom of the page and the last link is above every other link.

Design Choices
--------------
The vib browser is designed to be as minimal as possible. This results in tremendous customizability. For example, since vi/vim does not support ANSI escape sequences for color, the octal sequence \033 and \035 are used to delimit a label for a url because these characters are blue in vim. With a different text editor like ed, it might be possible to use ANSI escape sequences. It also does not handle the majority of html elements such as \<option\>: this should added when the parser is rewritten using flex/yacc.

Basic Features
--------------
- Go Back/Go Forward in History - Press u to undo and Ctrl-r/u to redo
- Searching for text - Press / to search forwards and ? to search backwards
- Copy - Press y[action] to copy
- Delete cookie - Remove cookie in cookie file
- Request a URL - Press \u and type [url]' followed by enter, where the url does not contain the protocol (https://)
- Click link - Search for \<link number\> and press \g at the beginning of the link number

For more features read the vi manpage.

Untested Features
-----------------
There is support for textarea elements, but this has yet to be tested. File upload is also supported via curl's -F option, but this is also untested.

Warnings
--------
In the vimrc mappings, it is necessary to prevent command injection from the url. Do not remove the quotes surrounding $(head -n 1), this is used to prevent the characters from being interpreted by the shell.

Other useful .bashrc functions
----------------------
	function google { echo -n "$*" | urlencode | get "https://www.google.com/search q=$(</dev/stdin)"; } 

	function searx { echo -n "$*" | urlencode | post "https://searx.xyz/search q=$(</dev/stdin)"; }

	function urlencode { 

	python3 -c 'from urllib.parse import quote_plus; import sys; print(quote_plus(sys.stdin.read()), end="")'; 

	}

Work In Progress
----------------
- Rewrite in flex/bison for portability and correctness

Bugs
----
Please send the website url and raw html to the email seL4@disroot.org, as well as any thing you have changed from the defaults.
