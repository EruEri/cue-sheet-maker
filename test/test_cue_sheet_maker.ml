open Cue_sheet_maker

let dizzy = 
  CueTrack.create_empty_track ~track:(1, AUDIO)
  |> CueTrack.add_performer ("喜多村英梨")
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "D!zzy...&"
  |> CueTrack.add_index (1, Duration.minute_seconde_millieme_format ~min: 3 ~sec:54 ~mil:992)
  |> CueTrack.add_rem ("Key", "value")
  |> CueTrack.add_rem ("Key2", "value2")

let synapse = 
  CueTrack.create_empty_track ~track:(2, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "古宇田亘"
  |> CueTrack.add_title "SynApsE"
  |> CueTrack.add_index (1, Duration.minute_seconde_millieme_format ~min: 3 ~sec:15 ~mil:827)
  |> CueTrack.add_rem ("Key", "value")
  |> CueTrack.add_rem ("Key2", "value2")
let () = 
  CueSheet.create_empty_sheet
  |> CueSheet.add_performer ("喜多村英梨")
  |> CueSheet.add_title "IЯiDÉSCEИT%V!SIØN"
  |> CueSheet.add_track dizzy
  |> CueSheet.add_track synapse
  |> CueSheet.string_of_cue_sheet ~sum: true
  |> print_endline