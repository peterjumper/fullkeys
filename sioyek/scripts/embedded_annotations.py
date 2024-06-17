'''
This script was tested with PyMuPDF version 1.17.6. Other versions may require slight modification of the code.

This script can be used to embed annotations as you create them, so they are viewable in other
PDF viewers.
This is basically a script that can either add a bookmark or a highlight to a page based on the command line arguments.
Here is the `prefs_user.config` that I used:

	execute_command_b python path/to/embedded_annotations.py bookmark "%1" %{mouse_pos_document} "%5"
	execute_command_h python path/to/embedded_annotations.py highlight "%1" "%4" "%3"

And here is a `keys_user.config` file that can be used:

	execute_command_b b
	execute_command_h;add_highlight h

which basically adds both sioyek and embedded highlights and bookmarks (if `ADD_BOOKMARKS_TO_SIOYEK` is True). Alternatively, you can use
a different keybinding for embedded annotations so you have control over what happens. Now you can use alt+b or alt+h to bookmark/highlight.

	execute_command_b <A-b>
	execute_command_h <A-h>
'''

import sys
import fitz
import subprocess

# if set to true, we re-add the bookmarks into sioyek, so we have both types of bookmarks
ADD_BOOKMARKS_TO_SIOYEK = True
PATH_TO_SIOYEK = r'/Applications/sioyek.app/Contents/MacOS/sioyek'

def add_bookmark(doc_path, page_number, location, text):
	doc = fitz.open(doc_path)
	page = doc.loadPage(page_number)
	page.addTextAnnot(location, text)
	doc.saveIncr()
	doc.close()
	if ADD_BOOKMARKS_TO_SIOYEK:
		subprocess.run([PATH_TO_SIOYEK, '--execute-command', 'add_bookmark','--execute-command-data', text])
		subprocess.run([PATH_TO_SIOYEK, '--execute-command', 'reload'])


def add_highlight(doc_path, page_number, text):
	doc = fitz.open(doc_path)
	page = doc.loadPage(page_number)
	quads = page.searchFor(text, flags=fitz.TEXT_PRESERVE_WHITESPACE, hit_max=50)
	page.addHighlightAnnot(quads)
	doc.saveIncr()
	doc.close()

def clean_path(path):
    if len(path) > 0:
        if path[0] == "'" or path[0] == '"':
            path = path[1:]
        if path[-1] == "'" or path[-1] == '"':
            path = path[:-1]
        return path
    else:
        return ""


# if __name__ == '__main__':
# 	if sys.argv[1] == 'bookmark':
# 		add_bookmark(clean_path(sys.argv[2]), int(clean_path(sys.argv[3])), float(clean_path(sys.argv[4])), float(clean_path(sys.argv[5])), clean_path(sys.argv[6]))

# 	if sys.argv[1] == 'highlight':
# 		add_highlight(sys.argv[2], int(sys.argv[3]), sys.argv[4])

if __name__ == '__main__':
    clean_args = [clean_path(arg) for arg in sys.argv]

    if sys.argv[1] == 'bookmark':
        add_bookmark(clean_args[2], int(clean_args[3]), (float(clean_args[4]), float(clean_args[5])), clean_args[6])

    if sys.argv[1] == 'highlight':
        add_highlight(clean_args[2], int(clean_args[3]), clean_args[4])
