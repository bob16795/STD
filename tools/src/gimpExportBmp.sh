#~/bin/wsl
# xcfs2png.sh
# Invoke The GIMP with Script-Fu convert-xcf-png
# No error checking.
{
cat <<EOF
(define (convert-xcf-png filename outpath)
    (let* (
            (image (car (gimp-xcf-load RUN-NONINTERACTIVE filename filename )))
            (drawable (car (gimp-image-merge-visible-layers image CLIP-TO-IMAGE)))
            )
        (begin (display "Exporting ")(display filename)(display " -> ")(display outpath)(newline))
        (file-bmp-save RUN-NONINTERACTIVE image drawable outpath outpath)
        (gimp-image-delete image)
    )
)

(gimp-message-set-handler 1) ; Messages to standard output
EOF

echo "(convert-xcf-png \"$1\" \"$2\")"

echo "(gimp-quit 0)"

} | gimp -i -b -