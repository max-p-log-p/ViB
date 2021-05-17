Tests
-----
To create a new test, add the raw html of a website with the suffix .html and the corresponding output of vib in another file without the suffix .html. Add the last url that curl has redirected to (-w %{url_effective}) as the last line of the raw html file. Add the line "check <website name>" in the script test.sh.
