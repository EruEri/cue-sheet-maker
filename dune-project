(lang dune 3.3)

(name cue_sheet_maker)

(generate_opam_files true)
(version 0.2.0)

(source
 (github EruEri/cue-sheet-maker))

(authors "EruEri")

(maintainers "EruEri")

(license MPL-2.0)

; (documentation https://url/to/documentation)

(package
 (name cue_sheet_maker)
 (synopsis "A library to create cue sheet")
 (depends 
    (ocaml (>= 4.14.0)) 
    dune
  )
 (tags
  ("Cue Sheet Maker")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
