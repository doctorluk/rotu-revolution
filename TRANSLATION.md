# Translating Call of Duty 4 Mods
This document describes the steps to prepare and compile a Call of Duty 4 mod in different languages.

## Instructions
Please follow these steps, in order to translate the mod.

1. Find the folder for your desired language

2. Open the *.str files in an editor and make sure the encoding is correct, if not change to the correct encoding

 2a. If the folder 'localizedstrings' inside your desired languages folder is empty, copy the files from the english/localizedstrings folder

 2b. Replace all 'LANG_ENGLISH' inside the file with the correct language tag, see below

 2c. Make sure the file encoding is correct

3. Translate the strings inside the .str files

4. Build the mod using the compile_mod.bat file, selecting the desired language

5. Test the mod, note that game versions will only have limited to no support for mods in other languages

##Valid languages

This is a list of all valid languages, their LANG tag and encoding

| Language   | Lang Tag        | Encoding     |
|------------|-----------------|--------------|
| english    | LANG_ENGLISH    | ANSI         |
| french     | LANG_FRENCH     | ANSI         |
| german     | LANG_GERMAN     | ANSI         |
| italian    | LANG_ITALIAN    | ANSI         |
| portuguese | LANG_PORTUGUESE | ANSI         |
| russian    | LANG_RUSSIAN    | Windows-1251 |
| spanish    | LANG_SPANISH    | ANSI         |