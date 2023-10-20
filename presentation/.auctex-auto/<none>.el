(TeX-add-style-hook
 "<none>"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "bigger")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem")))
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "lipsum"
    "inputenc"
    "fontenc"
    "graphicx"
    "longtable"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "amssymb"
    "capt-of"
    "hyperref")
   (LaTeX-add-labels
    "sec:org2aba2e3"
    "sec:org06043b2"
    "sec:org5111b66"
    "sec:org0512c9a"
    "sec:org02ca132"
    "sec:orgf18f515"
    "sec:org1c40554"
    "sec:orge7ee531"
    "sec:org56e2f7c"
    "sec:org5cdbc03"
    "sec:org8cc0642"))
 :latex)

