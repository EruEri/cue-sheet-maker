(**********************************************************************************************)
(*                                                                                            *)
(*  Copyright (C) 2023 Yves Ndiaye                                                            *)
(*                                                                                            *)
(* This Source Code Form is subject to the terms of the Mozilla Public                        *)
(* License, v. 2.0. If a copy of the MPL was not distributed with this                        *)
(* file, You can obtain one at https://mozilla.org/MPL/2.0/.                                  *)
(*                                                                                            *)
(**********************************************************************************************)

module Formating = struct
  let format_string_value s =
    if String.contains s ' ' then
      Printf.sprintf "\"%s\"" s
    else
      s
end

module CueFileFormat = struct
  type t = BINARY | MOTOROLA | AIFF | WAVE | MP3

  let string_of_cue_format = function
    | BINARY ->
        "BINARY"
    | MOTOROLA ->
        "MOTOROLA"
    | AIFF ->
        "AIFF"
    | WAVE ->
        "WAVE"
    | MP3 ->
        "MP3"

  let compare : t -> t -> int = Stdlib.compare
end

module CueTrackMode = struct
  type t =
    | AUDIO
    | CDG
    | MODE1_2048
    | MODE1_2352
    | MODE2_2336
    | MODE2_2352
    | CDI_2336
    | CDI_2352

  let string_of_cue_track_mode = function
    | AUDIO ->
        "AUDIO"
    | CDG ->
        "CDG"
    | MODE1_2048 ->
        "MODE1/2048"
    | MODE1_2352 ->
        "MODE1/2352"
    | MODE2_2336 ->
        "MODE2/2336"
    | MODE2_2352 ->
        "MODE2/2352"
    | CDI_2336 ->
        "CDI/2336"
    | CDI_2352 ->
        "CDI/2352"

  let compare : t -> t -> int = Stdlib.compare
end

module CueTrackFlag = struct
  type t = PRE | DCP | F_4CH | SCMS

  let string_of_cue_flag = function
    | PRE ->
        "PRE"
    | DCP ->
        "DCP"
    | F_4CH ->
        "4CH"
    | SCMS ->
        "SCMS"

  let compare : t -> t -> int = Stdlib.compare
end

module CD_Text = struct
  type t =
    [ `Arranger of string
    | `Composer of string
    | `Disc_Id of string
    | `Genre of string
    | `Isrc of string
    | `Message of string
    | `Performer of string
    | `Songwriter of string
    | `Title of string
    | `Toc_Info of string
    | `Toc_Info2 of string
    | `Upc_Ean of string
    | `Size_Info of string ]

  let compare : t -> t -> int = compare

  let string_of_cd_text =
    let open Printf in
    let open Formating in
    function
    | `Arranger s ->
        sprintf "%s %s" "ARRANGER" (format_string_value s)
    | `Composer s ->
        sprintf "%s %s" "COMPOSER" (format_string_value s)
    | `Disc_Id s ->
        sprintf "%s %s" "DISC_ID" (format_string_value s)
    | `Genre s ->
        sprintf "%s %s" "GENRE" (format_string_value s)
    | `Isrc s ->
        sprintf "%s %s" "ISCR" (format_string_value s)
    | `Message s ->
        sprintf "%s %s" "MESSAGE" (format_string_value s)
    | `Performer s ->
        sprintf "%s %s" "PERFORMER" (format_string_value s)
    | `Songwriter s ->
        sprintf "%s %s" "SONGWRITER" (format_string_value s)
    | `Title s ->
        sprintf "%s %s" "TITLE" (format_string_value s)
    | `Toc_Info s ->
        sprintf "%s %s" "TOC_INFO" (format_string_value s)
    | `Toc_Info2 s ->
        sprintf "%s %s" "TOC_INFO2" (format_string_value s)
    | `Upc_Ean s ->
        sprintf "%s %s" "UPC_EAN" (format_string_value s)
    | `Size_Info s ->
        sprintf "%s %s" "SIZE_INFO" (format_string_value s)
end

module CueTrackModeSet = Set.Make (CueTrackMode)
module CueTrackFlagSet = Set.Make (CueTrackFlag)
module RemsMap = Map.Make (String)
module IndexMap = Map.Make (Int)
module CD_TextSet = Set.Make (CD_Text)

module Duration = struct
  type duration =
    [ `MinSec of int * int
    | `MinSecMil of int * int * int
    | `MinSecFra of int * int * int ]

  let zero_frame = `MinSecFra (0, 0, 0)
  let minute_seconde_format ~min ~sec = `MinSec ((min : int), (sec : int))

  let minute_seconde_millieme_format ~min ~sec ~mil =
    `MinSecMil ((min : int), (sec : int), (mil : int))

  let minute_seconde_frame_format ~min ~sec ~frame =
    `MinSecFra ((min : int), (sec : int), (frame : int))

  let to_min_sec_fra = function
    | `MinSec (min, sec) ->
        `MinSecFra (min, sec, 0)
    | `MinSecMil (min, sec, mil) ->
        `MinSecFra
          (min, sec, mil |> float_of_int |> ( *. ) 0.075 |> int_of_float)
    | `MinSecFra _ as s ->
        s

  let add lhs rhs =
    let (`MinSecFra (l_min, l_sec, l_frame)) = to_min_sec_fra lhs in
    let (`MinSecFra (r_min, r_sec, r_frame)) = to_min_sec_fra rhs in

    let frame = (l_frame + r_frame) mod 75 in
    let retains_secon =
      if l_frame + r_frame > 75 then
        1
      else
        0
    in
    let seconde = (l_sec + r_sec + retains_secon) mod 60 in
    let retains_min =
      if l_sec + r_sec + retains_secon > 60 then
        1
      else
        0
    in
    `MinSecFra (l_min + r_min + retains_min, seconde, frame)

  let string_of_duration duration =
    let (`MinSecFra (min, sec, frame)) = to_min_sec_fra duration in
    Printf.sprintf "%02d:%02d:%02d" min sec frame
end

module CueTrack = struct
  type t = {
    track : int * CueTrackMode.t;
    flags : CueTrackFlagSet.t;
    pregap : [ `MinSecFra of int * int * int ] option;
    postgap : [ `MinSecFra of int * int * int ] option;
    cd_texts : CD_TextSet.t;
    rems : string RemsMap.t;
    indexes : [ `MinSecFra of int * int * int ] IndexMap.t;
  }

  let compare lhs rhs = compare (fst lhs.track) (fst rhs.track)

  let time_offset track =
    track.indexes |> IndexMap.bindings
    |> List.fold_left
         (fun acc (_, duration) -> Duration.add acc duration)
         Duration.zero_frame

  let string_of_cue_track ?(tabulation = false) ?(compute = None) track =
    let open Printf in
    let open CueTrackFlag in
    let open CueTrackMode in
    let cond_tab =
      if tabulation then
        "  "
      else
        String.empty
    in
    let index, track_mode = track.track in
    let str_track =
      sprintf "%sTRACK 0%d %s\n" cond_tab index
        (string_of_cue_track_mode track_mode)
    in
    let str_cd_texts =
      match CD_TextSet.is_empty track.cd_texts with
      | true ->
          String.empty
      | false ->
          track.cd_texts |> CD_TextSet.elements
          |> List.map CD_Text.string_of_cd_text
          |> String.concat (sprintf "\n  %s" cond_tab)
          |> sprintf "  %s%s\n" cond_tab
      (* if track.cd_texts = [] then
           ""
         else
           sprintf "  %s%s\n" cond_tab
             (track.cd_texts |> List.map string_of_cd_text
             |> String.concat (sprintf "\n  %s" cond_tab)
             ) *)
    in
    let str_flags =
      match CueTrackFlagSet.is_empty track.flags with
      | true ->
          String.empty
      | false ->
          track.flags |> CueTrackFlagSet.elements
          |> List.map string_of_cue_flag
          |> String.concat " "
          |> sprintf "  %sFLAGS %s\n" cond_tab
    in
    let str_rem =
      let mapper (key, value) = sprintf "  %sREM %s %s\n" cond_tab key value in
      match RemsMap.is_empty track.rems with
      | true ->
          ""
      | false ->
          track.rems |> RemsMap.bindings |> List.map mapper
          |> String.concat String.empty
    in
    let str_pregap =
      track.pregap
      |> Option.map (fun duration ->
             sprintf "  %sPREGAP %s\n" cond_tab
               (Duration.string_of_duration duration)
         )
      |> Option.value ~default:""
    in
    let str_postgap =
      track.postgap
      |> Option.map (fun duration ->
             sprintf "  %sPOSTGAP %s\n" cond_tab
               (Duration.string_of_duration duration)
         )
      |> Option.value ~default:""
    in
    let str_indexes =
      let compute_duration duration = function
        | `sum d ->
            Duration.add d duration
        | `set d ->
            Duration.to_min_sec_fra d
      in
      let string_of_index (track_index, duration) =
        let str_compute =
          compute
          |> Option.map (compute_duration duration)
          |> Option.value ~default:duration
          |> Duration.string_of_duration
        in
        sprintf "  %sINDEX 0%d %s" cond_tab track_index str_compute
      in
      match IndexMap.is_empty track.indexes with
      | true ->
          String.empty
      | false ->
          track.indexes |> IndexMap.bindings |> List.map string_of_index
          |> String.concat "\n"
    in
    sprintf "%s%s%s%s%s%s%s" str_track str_cd_texts str_flags str_rem str_pregap
      str_postgap str_indexes

  let create_empty_track ~track =
    {
      track;
      flags = CueTrackFlagSet.empty;
      pregap = None;
      postgap = None;
      cd_texts = CD_TextSet.empty;
      rems = RemsMap.empty;
      indexes = IndexMap.empty;
    }

  let add_index (index, time) track =
    {
      track with
      indexes = IndexMap.add index (Duration.to_min_sec_fra time) track.indexes;
    }

  let add_flag flag track =
    { track with flags = CueTrackFlagSet.add flag track.flags }

  let add_pregap duration track =
    { track with pregap = Some (Duration.to_min_sec_fra duration) }

  let add_postgap duration track =
    { track with postgap = Some (Duration.to_min_sec_fra duration) }

  let add_arranger arranger track =
    { track with cd_texts = CD_TextSet.add (`Arranger arranger) track.cd_texts }

  let add_composer composer track =
    { track with cd_texts = CD_TextSet.add (`Composer composer) track.cd_texts }

  let add_disc_id disc_id track =
    { track with cd_texts = CD_TextSet.add (`Disc_Id disc_id) track.cd_texts }

  let add_genre genre track =
    { track with cd_texts = CD_TextSet.add (`Genre genre) track.cd_texts }

  let add_isrc isrc track =
    { track with cd_texts = CD_TextSet.add (`Isrc isrc) track.cd_texts }

  let add_message message track =
    { track with cd_texts = CD_TextSet.add (`Message message) track.cd_texts }

  let add_performer performer track =
    {
      track with
      cd_texts = CD_TextSet.add (`Performer performer) track.cd_texts;
    }

  let add_songwriter songwriter track =
    {
      track with
      cd_texts = CD_TextSet.add (`Songwriter songwriter) track.cd_texts;
    }

  let add_title title track =
    { track with cd_texts = CD_TextSet.add (`Title title) track.cd_texts }

  let add_toc_info toc_info track =
    { track with cd_texts = CD_TextSet.add (`Toc_Info toc_info) track.cd_texts }

  let add_toc_info2 toc_info2 track =
    {
      track with
      cd_texts = CD_TextSet.add (`Toc_Info2 toc_info2) track.cd_texts;
    }

  let add_size_info size_info track =
    {
      track with
      cd_texts = CD_TextSet.add (`Size_Info size_info) track.cd_texts;
    }

  let add_rem (key, value) track =
    let key = String.uppercase_ascii key in
    let rems = RemsMap.add key value track.rems in
    { track with rems }

  let update_index (index, new_duration) track =
    match IndexMap.mem index track.indexes with
    | false ->
        track
    | true ->
        let indexes =
          IndexMap.add index
            (Duration.to_min_sec_fra new_duration)
            track.indexes
        in
        { track with indexes }
end

module CueTrackSet = Set.Make (CueTrack)

module CueSheet = struct
  module Inner_CDText = struct
    type t =
      [ `Arranger of string
      | `Composer of string
      | `Disc_Id of string
      | `Genre of string
      | `Message of string
      | `Performer of string
      | `Songwriter of string
      | `Title of string
      | `Toc_Info of string
      | `Toc_Info2 of string
      | `Size_Info of string ]

    let compare : t -> t -> int = compare
  end

  module Inner_CDTextSet = Set.Make (Inner_CDText)

  type t = {
    catalog : string option;
    cd_text_file : string option;
    cd_texts : Inner_CDTextSet.t;
    rems : string RemsMap.t;
    file : string * CueFileFormat.t;
    tracks : CueTrackSet.t;
  }

  let create_empty_sheet ~file =
    {
      catalog = None;
      cd_text_file = None;
      cd_texts = Inner_CDTextSet.empty;
      rems = RemsMap.empty;
      file;
      tracks = CueTrackSet.empty;
    }

  let string_of_cue_sheet ?(sum = false) cue_sheet =
    let open Printf in
    let open Formating in
    let str_catalog =
      cue_sheet.catalog
      |> Option.map format_string_value
      |> Option.map (sprintf "CATALOG %s\n")
      |> Option.value ~default:""
    in
    let str_cd_text_file =
      cue_sheet.cd_text_file
      |> Option.map format_string_value
      |> Option.map (sprintf "CDTEXTFILE %s\n")
      |> Option.value ~default:""
    in
    let str_cd_texts =
      match Inner_CDTextSet.is_empty cue_sheet.cd_texts with
      | true ->
          String.empty
      | false ->
          cue_sheet.cd_texts |> Inner_CDTextSet.elements
          |> List.map CD_Text.string_of_cd_text
          |> String.concat "\n" |> sprintf "%s\n"
    in
    let str_rems =
      let mapper (key, value) = sprintf "REM %s %s\n" key value in
      match RemsMap.is_empty cue_sheet.rems with
      | true ->
          String.empty
      | false ->
          cue_sheet.rems |> RemsMap.bindings |> List.map mapper
          |> String.concat String.empty
    in
    let str_file =
      cue_sheet.file
      |> fun (file_name, format) ->
      sprintf "FILE \"%s\" %s\n" file_name
        (CueFileFormat.string_of_cue_format format)
    in
    let str_tracks =
      cue_sheet.tracks |> CueTrackSet.elements
      |> List.fold_left_map
           (fun acc track ->
             let offset = track |> CueTrack.time_offset |> Duration.add acc in
             let str_cue =
               CueTrack.string_of_cue_track ~tabulation:true
                 ~compute:
                   ( if sum then
                       Some (`set acc)
                     else
                       None
                   )
                 track
             in
             (offset, str_cue)
           )
           Duration.zero_frame
      |> snd |> String.concat "\n"
    in
    sprintf "%s%s%s%s%s%s\n" str_catalog str_cd_text_file str_cd_texts str_rems
      str_file str_tracks

  let add_catalog catalog sheet = { sheet with catalog = Some catalog }

  let add_cd_text_file cd_text_file sheet =
    { sheet with cd_text_file = Some cd_text_file }

  let add_arranger arranger sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Arranger arranger) sheet.cd_texts;
    }

  let add_composer composer sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Composer composer) sheet.cd_texts;
    }

  let add_disc_id disc_id sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Disc_Id disc_id) sheet.cd_texts;
    }

  let add_genre genre sheet =
    { sheet with cd_texts = Inner_CDTextSet.add (`Genre genre) sheet.cd_texts }

  let add_message message sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Message message) sheet.cd_texts;
    }

  let add_performer performer sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Performer performer) sheet.cd_texts;
    }

  let add_songwriter songwriter sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Songwriter songwriter) sheet.cd_texts;
    }

  let add_title title sheet =
    { sheet with cd_texts = Inner_CDTextSet.add (`Title title) sheet.cd_texts }

  let add_toc_info toc_info sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Toc_Info toc_info) sheet.cd_texts;
    }

  let add_toc_info2 toc_info2 sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Toc_Info2 toc_info2) sheet.cd_texts;
    }

  let add_size_info size_info sheet =
    {
      sheet with
      cd_texts = Inner_CDTextSet.add (`Size_Info size_info) sheet.cd_texts;
    }

  let add_rem (key, value) sheet =
    let key = String.uppercase_ascii key in
    let rems = RemsMap.add key value sheet.rems in
    { sheet with rems }

  let add_track (track : CueTrack.t) sheet =
    { sheet with tracks = CueTrackSet.add track sheet.tracks }

  let export ?(sum = false) output sheet =
    try
      let str_sheet = sheet |> string_of_cue_sheet ~sum in
      let out_chan = open_out output in
      Out_channel.output_string out_chan str_sheet;
      Out_channel.close out_chan |> Result.ok
    with e -> Error e
end
