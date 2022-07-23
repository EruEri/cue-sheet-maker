open Cue_sheet_maker

let () = 
  CueTrack.create_empty_track ~track:(1, AUDIO)
  |> CueTrack.add_performer ("喜多村英梨")
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "D!zzy...&"
  |> CueTrack.add_index (1, Duration.minute_seconde_millieme_format ~min: 3 ~sec:54 ~mil:992)
  |> CueTrack.add_rem ("Key", "value")
  |> CueTrack.add_rem ("Key2", "value2")
  |> CueTrack.string_of_cue_track
  |> print_endline
