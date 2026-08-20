Species Data CSV folder
========================

If you're running this app locally (via Launch_map_Windows.bat or
Launch_map_MAC.command), save your species-distribution CSV file(s) into this
folder. Open the app, go to Map Tools -> Species Data (CSV), and it will list
any .csv files found here so you can load one with a click - no need to browse
for it each time.

You can still use the "Drag & drop a CSV here, or click to browse" option to
load a file from anywhere else on your computer instead.

Your CSV needs at least a latitude column and a longitude column (any header
names are fine - you pick which column is which after loading). A species/name
column is optional and will be used to label points on the map.

Note: this folder listing only works when running the app locally through
server.js. On the hosted (GitHub Pages) version of this map, there is no
server to list files from, so loading is always done via drag-and-drop or
browse, for that browser session only.

CSV files placed in this folder are not uploaded anywhere or committed to the
project's GitHub repository (see .gitignore) - they stay on your computer.
