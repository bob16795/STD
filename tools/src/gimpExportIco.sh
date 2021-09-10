#!/bin/bash
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

echo "(convert-xcf-png \"$1\" \"$2.bmp\")"

echo "(gimp-quit 0)"

} | gimp -i -b -

convert $2.bmp  -bordercolor white -border 0 \
          \( -clone 0 -resize 16x16 \) \
          \( -clone 0 -resize 32x32 \) \
          \( -clone 0 -resize 48x48 \) \
          \( -clone 0 -resize 64x64 \) \
          -delete 0 -alpha off -colors 256 $2
rm $2.bmp