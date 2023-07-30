open Cue_sheet_maker

let dizzy =
  CueTrack.create_empty_track ~track:(1, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "D!zzy...&"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:54 ~mil:992)

let synapse =
  CueTrack.create_empty_track ~track:(2, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "古宇田亘"
  |> CueTrack.add_title "SynApsE"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:15 ~mil:827)

let egoism =
  CueTrack.create_empty_track ~track:(3, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "ヱゴヰズム"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:22 ~mil:147)

let anger =
  CueTrack.create_empty_track ~track:(4, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Han"
  |> CueTrack.add_title "ANGER%"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:5 ~sec:12 ~mil:449)

let kindan_kajitsu =
  CueTrack.create_empty_track ~track:(5, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Han"
  |> CueTrack.add_title "禁断果実"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:12 ~mil:565)

let belief_in_oneself =
  CueTrack.create_empty_track ~track:(6, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Han"
  |> CueTrack.add_title "Belief in Oneself"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:29 ~mil:798)

let shine_going_up =
  CueTrack.create_empty_track ~track:(7, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "YutoMinami"
  |> CueTrack.add_title "SH!NE GO!NG UP"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:4 ~sec:23 ~mil:883)

let holy_shit =
  CueTrack.create_empty_track ~track:(8, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "HOLy×SH!T"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:4 ~sec:29 ~mil:836)

let eternity =
  CueTrack.create_empty_track ~track:(9, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "ETERNiTY"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:4 ~sec:32 ~mil:006)

let nijiiro =
  CueTrack.create_empty_track ~track:(10, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "古宇田亘"
  |> CueTrack.add_title "虹色"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:59 ~mil:187)

let egoism_mix =
  CueTrack.create_empty_track ~track:(11, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Village wood"
  |> CueTrack.add_title "ヱゴヰズム (- Pf MiX -)"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:33 ~mil:684)

let kindan_kajitsu_mix =
  CueTrack.create_empty_track ~track:(12, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "Han"
  |> CueTrack.add_title "禁断果実 (- Pf MiX -)"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:3 ~sec:22 ~mil:723)

let shine_going_up_mix =
  CueTrack.create_empty_track ~track:(13, AUDIO)
  |> CueTrack.add_performer "喜多村英梨"
  |> CueTrack.add_composer "YutoMinami"
  |> CueTrack.add_title "SH!NE GO!NG UP (- Pf MiX -)"
  |> CueTrack.add_index
       (1, Duration.minute_seconde_millieme_format ~min:4 ~sec:40 ~mil:965)

let () =
  CueSheet.create_empty_sheet ~file:("", WAVE)
  |> CueSheet.add_performer "喜多村英梨"
  |> CueSheet.add_title "IЯiDÉSCEИT%V!SIØN"
  |> CueSheet.add_track dizzy |> CueSheet.add_track synapse
  |> CueSheet.add_track egoism |> CueSheet.add_track anger
  |> CueSheet.add_track kindan_kajitsu
  |> CueSheet.add_track belief_in_oneself
  |> CueSheet.add_track shine_going_up
  |> CueSheet.add_track holy_shit
  |> CueSheet.add_track eternity
  |> CueSheet.add_track nijiiro
  |> CueSheet.add_track egoism_mix
  |> CueSheet.add_track kindan_kajitsu_mix
  |> CueSheet.add_track shine_going_up_mix
  |> CueSheet.string_of_cue_sheet ~sum:true
  |> print_endline
