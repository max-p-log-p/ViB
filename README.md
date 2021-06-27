ViB - Browser in Vi (Vim-Minimal)
=================================

Why should I use this browser?
------------------------------

This browser has many capabilities due to its extensibility: the vi interface is reused to support a text based web browser. It is portable to any operating system with python3, vi, and curl installed. It has limited support for javascript.

Basic Features
--------------
- Request a URL - \u <url>
- Click link - \g <link number>
- Send a form - \f <link number> [-G]
- Tabs (no nvi support) - :tabnew
- Go Back in History - u
- Go Forward in History - Ctrl-r (vim) / u (nvi)
- Search forwards - / 
- Search backwards - ?
- Copy - y[motion]
- Delete cookie - Remove cookie in cookie file
- Get raw html - :%!. ~/.vibrc; html "$(tail -1)" (1 is link for current page)
- Javascript - Get raw html, interpret manually and edit html, reparse with %!. ~/.vibrc; vib
- Inspect Element - Get raw html, edit html, reparse with %!. ~/.vibrc; vib
- Windows - open in a new window with tmux
- PDF viewer - :%!. ~/.vibrc; html "$(tail -10 | head -1)" | pdftotext - - (requires pdftotext)
- Images, Video, etc. - Install an application that handles the file format and reads from standard input. Pipe the output to the application.
- History - Use :his to list history. For persistent history, modify a function to append the requested url to a file.
- Bookmarks - Maintain a bookmarks file with links
- Hide Password - Cover with physical object.
- Debugging - add --trace (:%!. ~/.vibrc; url https://www.google.com --trace)
- File Upload - Use -F for each parameter in the file. See the section Links.

For more features read the ex/vi manpage.

How to use
----------
Copy the .vibrc file to your home directory and change /path/to/vib in the function vib() to the path to the vib file.

Add the following mappings to the configuration file of your version of vi:

	map \g mg:%!. ~/.vibrc; get 

	map \f :%!. ~/.vibrc; form

	map \u :%!. ~/.vibrc; url https://

	map \j mjyw:$+-

The \g mapping is used for clicking links. After undo, the mg command is used to allow the user to return to the original position by entering \`g. The \f mapping is used for http requests that send form data. To send a form with get data, type \f, followed by the link number and -G. To send a form with post data, type \f followed by the link number. The \j mapping is used to find the link corresponding to a link number. To return to the original link, press \`j. The \u mapping is used to request a url.

.vibrc
------
The form function performs a HTTP request that sends form data to the server. The google function allows you to search google by typing in the search query like this: google vib browser. The vib function allows the user to modify the html to fix errors or manually interpret javascript followed by a reparsing of the webpage. The urlencode function performs url encoding. The user agent is provided in each of the functions in the -A option because some websites do not work with curl's user agent. The cookie_file is provided in the -b and -c option if one wishes to maintain the state of an HTTP session. The --compressed option allows for faster requests and allows support for servers that send gzipped data regardless of the Accept: Encoding header. The --data-raw option is necessary to send data in GET and POST requests. The -L option is convenient because it enables curl to perform redirects. The 2>&1 argument prevents curl from creating a blank line at the top of the file. Finally, the option -w is necessary for the python script to work: it assumes that the last url that curl requested is in the last line of the data. For more information about the options, read the curl manpage. 

The sed command `s/[^^[-~]/࿽/g` in the function vib replaces any characters that are not in the range from 27 to 126 inclusive with the UTF-8 form feed replacement character (0xfffd). For more information, read the sed manpage. 

Links
-----
At the bottom of a parsed webpage are links.

https://www.google.com/search q=

Each link has a URL and data which are separated by the first space, ' '. Edit the data to use it to make searches, login to websites, and more. For example, modifying the above to search google would look like this: 

https://www.google.com/search q=how+do+I+install+w3m

The data must be urlencoded. For urlencoding, you can use the urlencode function.

Each link has a link number which corresponds to the number of lines it is from the bottom of the file, starting with 1 as the last line of the file. Links are written in reverse so that the first link is at the bottom of the page and the last link is above every other link.

The last line of the file always corresponds to the current url of the webpage. This allows one to easily retrieve the raw html of the webpage by changing the url to "$(tail -1)". 

Links without form data (do not require user input) have the following format: ^[\<link number\>^] (e.g. ^[5^]). 

Links with form data (require user input) have the following format: ^[\<link number\> \<action\>^] [method] [enctype] (e.g. ^[5 /search^] get application/x-www-form-urlencoded).

The action is shown to give the user an idea of what the link is used for. In the example above, /search implies that the link is used for searching.

The method is shown to let the user know which method they should use to send data. If the method is get or if the method is not shown, the user should append -G when sending the data (e.g. :. ~/.vibrc; form 28 -G). It the method is post, the user should not append -G when sending the data (e.g. :. ~/.vibrc; form 28).

The enctype value application/x-www-form-urlencoded or its absence is the default enctype which means that the user should use the vi mapping \f to send the data. The enctype value multipart/form-data means that the user needs to manually uspecify parameters to send the data. If a parameter has a default value of '@', then it the user should specify a file to send. 

For example, a link with a link number of 28 and enctype of multipart/form-data that looks like

http://www.tipjar.com/cgi-bin/test image=@&test=

would require the user to type 

:. ~/.vibrc; html "$(tail -n 28)" -F image=@/tmp/test -F test=a

to send the file /tmp/test with the test parameter having a value of a.

A link with a link number of 5 and no enctype that looks like 

http://www.tipjar.com/cgi-bin/test image=test&test=test2

would require the user to type 

:. ~/.vibrc; form 28

or \f 28 as a shortcut to send the image parameter with a value of test and test parameter with a value of test2.

Warnings
---------------
Many web pages have invalid html. It is possible to fix this by getting the raw html, manually fixing the error, then reparsing with %!. ~/.vibrc; vib.

It is wise to compile curl without most of its support for various protocols if you don't need it. Curl has frequent vulnerabilities in those protocols, they may allow for disclosure of sensitive data/command execution, and the --proto, --proto-default, and --proto-redir options may be bypassed by an attacker.

OpenBSD nvi will complain that 'The ! command doesn't permit an address of 0.' with an empty file. Modify the file to fi this.

Do not paste urls into the ex prompt: first paste them into an empty file, then use the \g mapping to request the url. Otherwise, vi/vim could potentially interpret some characters as shell metacharacters and execute commands. If the google search query has weird metacharacters, escape the metacharacters with a backslash or type the search query into the file and use a command like google "$(tail -1)" instead (assuming the query is on the last line of the file).

It may be possible to use protocol smuggling to attempt a client side request forgery attack. If possible, use the web browser in a network namespace/virtual environment or ensure that services running have some sort of client side request forgery protection.

Work In Progress
----------------
- Rewrite in flex/bison for portability and correctness

Bugs
----
Please send the website url and raw html to the email seL4@disroot.org, as well as any thing you have changed from the defaults.
