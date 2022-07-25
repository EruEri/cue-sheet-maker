# Cue_sheet_maker
A library to create cue sheet

## Installation

Cue_sheet_maker is available as an opam package:
```
opam install cue_sheet_maker
```

## Example

A simple example on how to create a cue sheet

```ocaml
open Cue_sheet_maker

let track = 
  CueTrack.create_empty_track ~track:(1, AUDIO)
  |> CueTrack.add_performer "A performer"
  |> CueTrack.add_composer "A composer"
  |> CueTrack.add_title "A title"
  |> CueTrack.add_index (1, Duration.minute_seconde_millieme_format ~min: 3 ~sec:30 ~mil: 300)
  
let track2 = 
  CueTrack.create_empty_track ~track:(2, AUDIO)
  |> CueTrack.add_performer "A performer 2"
  |> CueTrack.add_composer "A composer 2"
  |> CueTrack.add_title "A title 2"
  |> CueTrack.add_index (1, Duration.minute_seconde_millieme_format ~min: 3 ~sec:10 ~mil: 300)
  
let sheet = 
  CueSheet.create_empty_sheet ~file:("A file", WAVE)
  |> CueSheet.add_catalog "0123456789123"
  |> CueSheet.add_performer "Album performer"
  |> CueSheet.add_title "Album title"
  |> CueSheet.add_track track
  |> CueSheet.add_track track2

let result = sheet |> CueSheet.export ~sum: true "output.cue"
```

Produce

```
CATALOG 0123456789123
TITLE "Album title"
PERFORMER "Album performer"
FILE "A file" WAVE
  TRACK 01 AUDIO
    TITLE "A title"
    COMPOSER "A composer"
    PERFORMER "A performer"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "A title 2"
    COMPOSER "A composer 2"
    PERFORMER "A performer 2"
    INDEX 01 03:30:22
```
