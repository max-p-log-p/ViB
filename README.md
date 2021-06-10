ViB - Browser in Vi (Vim-Minimal)
=================================

Why should I use this browser?
------------------------------

This browser has many capabilities due to its extensibility: the vi interface is reused to support a text based web browser. It is portable to any operating system with python3, vi, and curl installed. It has limited support for javascript and modifying/searching html via human cognition. Despite its name, vib can be used with many different text editors.

How to use
----------
Copy the .vibrc file to your home directory and change /path/to/vib to the path to the vib file.

Add the following mappings to the configuration file of your version of vi:

	map \g mg:%!. ~/.vibrc; get 

	map \f :%!. ~/.vibrc; form --data-raw 

	map \u :%!. ~/.vibrc; url https://

	map \j mjyw:$+-

The \g mapping is used for clicking links. After undo, the mg command is used to allow the user to return to the original position by entering `g. The \f mapping is used for http requests that send form data. To send a form with get data, type \f, followed by the link number and -G. To send a form with post data, type \f followed by the link number. To send a form with a file, change the --data-raw to -F followed by typing the link number. The \j mapping is used to find the link corresponding to a link number. To return to the original link, press `j. The \u mapping is used to request a url.

.vibrc
------
The names of the functions are arbitrary but will be used later in your .vimrc file. 

The form function performs a HTTP request that sends form data to the server. The google function allows you to search google by typing in the search query like so: google vib browser. The vib function allows the user to modify the html to fix errors or manually interpret javascript followed by a reparsing of the webpage. The urlencode function performs url encoding. The user agent is provided in each of the functions in the -A option because some websites do not work with curl's user agent. The cookie_file is provided in the -b and -c option if one wishes to maintain the state of an HTTP session. The --compressed option allows for faster requests and allows support for servers that send gzipped data regardless of the Accept: Encoding header. The --data-raw option is necessary to send data in GET and POST requests. The -L option is convenient because it enables curl to perform redirects. The 2>&1 argument prevents curl from creating a blank line at the top of the file. Finally, the option -w is necessary for the python script to work: it assumes that the last url that curl requested is in the last line of the data. For more information about the options, read the curl manpage. 

The sed command `s/^[[:space:]]*|[^^[-~]//g` in the function vib strips out any leading white space characters or characters that are not in the range from 27 to 126 inclusive: this allows for the removal of characters that do not display well in vim but may be changed to support UTF-8 characters. The command `/^$/d` deletes blank lines. For more information, read the sed manpage. 

Links
-----
By default, the vib script will output lines at the bottom of a parsed webpage, looking like this:

https://lwn.net/Login/newaccount submit=Register

The first component is the URL. The second component is the data to be sent via GET/POST request. It is possible to edit or fill in this data and use it to make searches, login to websites, etc. When editing the data, make sure it is urlencoded. Urlencoded data can be obtained by piping the data to the urlencode function.

Form labels can be understood in the following way: ^[<link number> <action>^] [method] [enctype].

^[5 /search^] get application/x-www-form-urlencoded

The enctype value application/x-www-form-urlencoded or its absence means that the user should use --data-raw to send the form data. The enctype value multipart/form-data means that the user should use -F to send a file. The specific parameter to specify the file path will have a default value of the '@' character. 

Link labels can be understood in the following way: ^[<link number>^].

^[5^]

The last line of the file always corresponds to the current url of the webpage. This allows one to easily retrieve the raw html of the webpage by changing the url to "$(tail -1)". Links are written in reverse so that the first link is at the bottom of the page and the last link is above every other link.

Design Choices
--------------
Since vi/vim does not support ANSI escape sequences for color, the octal sequence \033 and \035 are used to delimit a label for a url because these characters are blue in vim. With a different text editor like ed, it might be possible to use ANSI escape sequences.

Basic Features
--------------
- Go Back/Go Forward in History - Press u to undo and Ctrl-r/u to redo
- Searching for text - Press / to search forwards and ? to search backwards
- Copy - Press y[motion] to copy
- Delete cookie - Remove cookie in cookie file
- Request a URL - Press \u and enter url
- Send a form - Press \f, followed by link number. Append -G if get request
- Click link - Press \g, followed by link number
- Get raw html - :%!. ~/.vibrc; html "$(tail -1)"
- Javascript - Get raw html, interpret manually and edit html, reparse with %!vib
- Inspect Element - Get raw html, search with /, edit html with vim, reparse with %!vib
- Open in new tab - Press \u and enter url, press Ctrl-b, type 'tabnew|' and press enter
- Open in new window - open vi/vim in a new window with tmux
- Debugging - add --trace to curl
- Images, Video, etc. - Download manually with the html function and view in another application
- History - Use :his to list history. For persistent history, append the requested url to a file in the desired ~/.bashrc function.
- Bookmarks - Maintain a bookmarks file with link numbers
- File Upload - Press \f, change --data-raw to -F, type link number
- Hide Password - Set lines to 4 with :set lines=4, enter insert mode, press Ctrl-S, type password, exit insert mode, press `j, press Ctrl-Q. Alternatively, hide the password with your hands.
- Textarea - Use %0D%0A for lines breaks with --data to send the data, or use a temporary file and send the data with --data-binary @/path/to/file

For more features read the ex/vi manpage.

Warnings/Errata
---------------
Many web pages have invalid html. It is possible to fix this by getting the raw html, manually fixing the error, then reparsing with %!vib.

It is wise to compile curl without most of its support for various protocols if you don't need it. Curl has frequent vulnerabilities in those protocols, they may allow for disclosure of sensitive data/command execution, and the --proto, --proto-default, and --proto-redir options may be bypassed by an attacker.

For OpenBSD nvi, you need to start with a nonempty file otherwise nvi will complain that 'The ! command doesn't permit an address of 0.'

Do not paste urls into the ex prompt: first paste them into an empty file, then use the \g mapping to request the url. Otherwise, vi/vim could potentially interpret some characters as shell metacharacters and execute commands.

Work In Progress
----------------
- Rewrite in flex/bison for portability and correctness

Bugs
----
Please send the website url and raw html to the email seL4@disroot.org, as well as any thing you have changed from the defaults.
