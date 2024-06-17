
I have the same problem as you, which is reproducible on many PDF files. I found that the problem exists at:

https://github.com/ahrm/sioyek-python-extensions/blob/b2b17e0b78e990b6544e534682ea66e154bf6272/src/sioyek/sioyek.py#L843-L850

I found some cases when absolute begin is after the absolute end, causing this part of the code to select the entire page for highlighting.

You can open prefs_user.config, typically where you configed sioyek_python_extensions, and change embedding command to:

new_command _embed_annotations python3 -m sioyek.embed_annotations "%{sioyek_path}" "%{local_database}" "%{shared_database}" "%{file_path}" "fitz"

Then everything works fine, tested from my end.
