
date folder or extensions/date
	date.pad
	date[ format ] - There are a few different ones....
	months {}, days {} -- links to i18n
	account for dst
	depending on locale, youll have to move times up or down
	
HTTP/1.0 200 OK
Content-type: text/html
Set-Cookie: name=value
Set-Cookie: name2=value2; Expires=Wed, 09 Jun 2021 10:18:14 GMT
 
(content of page)

os folder, extension/os or os.lua
	checks what type of os is being run and does some things
	like set new lines
	device files
	socket lib choices

debug folder
	different console functions can go here
	wrapping for the gratuitous response.abort methods (for example:
		o = table.exists({ }) or die({term})
reorganize the interface by single files

come up with a smarter require loop

hold content types here?
