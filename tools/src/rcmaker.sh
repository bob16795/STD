contents() {
echo "id ICON \"content/icon.ico\""
echo "1 VERSIONINFO"
echo -n "FILEVERSION  "
cat $1 | sed "s/\./,/g
              s/-/,/g"
echo -n "PRODUCTVERSION  "
cat $1 | sed "s/\./,/g
              s/-/,/g"
cat <<EOF
BEGIN
  BLOCK "StringFileInfo"
  BEGIN
    BLOCK "080904E4"
    BEGIN
      VALUE "CompanyName", "Prestosilver"
      VALUE "FileDescription", "STD"
      VALUE "FileVersion", "$$1$$"
      VALUE "InternalName", "STD"
      VALUE "OriginalFilename", "STD.exe"
    END
  END
  BLOCK "VarFileInfo"
  BEGIN
    VALUE "Translation", 0x809, 1252
  END
END
EOF
}

ver=$(cat $1 | sed -s 's/-/./')
contents $1 | sed -s "s/\$\$1\$\$/$ver/g" > $2