# epub2obsidian

Bash / Shell script converting an epub file to [Obsidian](https://obsidian.md)-flavored markdown.

The script uses `pandoc`, `perl` and `awk`, all available through your usual package manager if not installed.

Usage
=====
```
Usage : ./epub2obsidian.sh -i <input> -o <output> --code-lang <language>

             -i  input filename (epub)
             -o  output filename (.md)
    --code-lang  language for code blocks highlights
```