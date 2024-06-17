# import sys
# from googletrans import Translator

# from .sioyek import Sioyek, clean_path
# import pyperclip


# if __name__ == '__main__':
#     sioyek_path = clean_path(sys.argv[1])
#     text = sys.argv[2]
#     sioyek = Sioyek(sioyek_path)
#     translator = Translator()
#     # translation = translator.translate(text, dest='en')
#     translation = translator.translate(text, dest='zh-cn')  # Translate to Simplified Chinese first
#     translation = translator.translate(translation.text, dest='zh-tw')  # Translate to Traditional Chinese
#     sioyek.set_status_string(translation.text)

#      # Copy the translated text to the clipboard
#     pyperclip.copy(translated.text)

import sys
import os

if __name__ == '__main__':
    text = sys.argv[1]
    os.system('say ' + text)


