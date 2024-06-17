import sys
import os

if __name__ == '__main__':
    file_path = sys.argv[1]
    new_path = file_path.split('.')[0] + '_new.pdf'
    os.system('ocrmypdf "' + file_path + '" "' + new_path + '"')
    # os.system('pdfcpu nup "' + new_path + '" "' + '4' + file_path + '"')
    os.system('sioyek "' + new_path + '"')



    # %1 expands to the path of the current file
    # %2 expands to just the file name of the current file
    # %3 expands to the selected text
    # %4 expands to the current page number
    # %5 expands to an input text which is received from the user using a text prompt
    # %6 expands to the text of the current line in sioyek’s visual line mode


