type cue_file_format = 
  | BINARY
  | MOTOROLA
  | AIFF
  | WAVE
  | MP3
;;

let string_of_cue_format = function
| BINARY -> "BINARY"
| MOTOROLA -> "MOTOROLA"
| AIFF -> "AIFF"
| WAVE -> "WAVE"
| MP3 -> "MP3"

type cue_track_mode = 
  | AUDIO
  | CDG
  | MODE1_2048
  | MODE1_2352
  | MODE2_2336
  | MODE2_2352
  | CDI_2336
  | CDI_2352 
;;

let string_of_cue_track_mode = function
| AUDIO -> "AUDIO"
| CDG -> "CDG"
| MODE1_2048 -> "MODE1/2048"
| MODE1_2352 -> "MODE1/2352"
| MODE2_2336 -> "MODE2/2336"
| MODE2_2352 -> "MODE2/2352"
| CDI_2336 -> "CDI/2336"
| CDI_2352 -> "CDI/2352"  

type cue_track_flag = 
| PRE
| DCP
| F_4CH
| SCMS
;;

let string_of_cue_flag = function
| PRE -> "PRE"
| DCP -> "DCP"
| F_4CH -> "4CH"
| SCMS -> "SCMS"


type cd_text = [
  `Arranger of string
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
| `Size_Info of string
]

let format_string_value s = 
  if String.contains s ' ' then Printf.sprintf "\"%s\"" s else s
let string_of_cd_text = let open Printf in function
| `Arranger s -> sprintf "%s %s" "ARRANGER" (format_string_value s)
| `Composer s -> sprintf "%s %s" "COMPOSER" (format_string_value s)
| `Disc_Id s -> sprintf "%s %s" "DISC_ID"  (format_string_value s)
| `Genre s -> sprintf "%s %s" "GENRE"  (format_string_value s)
| `Isrc s -> sprintf "%s %s" "ISCR"  (format_string_value s)
| `Message s -> sprintf "%s %s" "MESSAGE"  (format_string_value s)
| `Performer s -> sprintf "%s %s" "PERFORMER"  (format_string_value s)
| `Songwriter s -> sprintf "%s %s" "SONGWRITER"  (format_string_value s)
| `Title s -> sprintf "%s %s" "TITLE"  (format_string_value s)
| `Toc_Info s -> sprintf "%s %s" "TOC_INFO"  (format_string_value s)
| `Toc_Info2 s -> sprintf "%s %s" "TOC_INFO2"  (format_string_value s)
| `Upc_Ean s -> sprintf "%s %s" "UPC_EAN"  (format_string_value s)
| `Size_Info s -> sprintf "%s %s" "SIZE_INFO"  (format_string_value s)


module Duration = struct
  type duration = [
    `MinSec of (int*int)
  | `MinSecMil of (int*int*int)
  | `MinSecFra of (int*int*int)
  ]

let minute_seconde_format ~min ~sec = `MinSec ( (min: int), (sec: int) )
let minute_seconde_millieme_format ~min ~sec ~mil = `MinSecMil (  (min: int), (sec: int), (mil: int) )
let minute_seconde_frame_format ~min ~sec ~frame = `MinSecFra (  (min: int), (sec: int), (frame: int) )

let to_min_sec_fra = function
| `MinSec (min, sec) -> `MinSecFra (min, sec, 0)
| `MinSecMil (min, sec, mil) -> `MinSecFra (min, sec, (mil |> float_of_int |> ( *. ) 0.075 |> int_of_float) )
| `MinSecFra _ as s -> s
let duration_add lhs rhs = 
  let `MinSecFra (l_min, l_sec, l_frame) = to_min_sec_fra lhs in
  let `MinSecFra (r_min, r_sec, r_frame) = to_min_sec_fra rhs in

  let frame = (l_frame + r_frame) mod 75 in
  let retains_secon = if l_frame + r_frame > 75 then 1 else 0 in
  let seconde = (l_sec + r_sec + retains_secon) mod 60 in
  let retains_min = if l_sec + r_sec + retains_secon > 60 then 1 else 0 in
  `MinSecFra (l_min + r_min + retains_min, seconde, frame)

  let string_of_duration duration = 
    let `MinSecFra (min, sec, frame ) = to_min_sec_fra duration in
    Printf.sprintf "%02d:%02d:%02d" min sec frame
;;
end

module CueTrack = struct
  type cue_track = {
    track: int*cue_track_mode ;
    flags: cue_track_flag list;
    pregap: [`MinSecFra of (int*int*int)] option;
    postgap: [`MinSecFra of (int*int*int)] option;
    cd_texts : [
      `Arranger of string 
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
    | `Size_Info of string
    ] list;
    rems: (string, string) Hashtbl.t;
    indexs: (int* [`MinSecFra of (int*int*int)]) list;
  }


  let sort_index track = {
    track with indexs = track.indexs |> List.sort (fun (li, _)  (ri, _) -> compare li ri )
  }

  let string_of_cue_track ?(tabulation = false) ?(sum = None) track =
    let open Printf in
    let cond_tab = (if tabulation then "\t" else "") in
    let track = sort_index track in
    let index, track_mode = track.track in
    let str_track = sprintf "%sTRACK 0%d %s\n" (cond_tab) (index) (string_of_cue_track_mode track_mode) in
    let str_cd_texts = if track.cd_texts = [] then "" else  sprintf "\t%s%s\n" (cond_tab) (track.cd_texts |> List.map (string_of_cd_text) |> String.concat (sprintf "\n\t%s" (cond_tab))) in
    let str_flags = if track.flags = [] then "" else sprintf "\t%sFLAGS %s\n" (cond_tab) (track.flags |> List.map (string_of_cue_flag) |> String.concat " ") in
    let str_rem = if track.rems |> Hashtbl.length = 0 then "" else track.rems |> Hashtbl.to_seq |> Seq.map (fun (key, value) -> sprintf "\t%sREM %s %s\n" cond_tab key value) |> List.of_seq |> List.rev |> String.concat (sprintf "" ) in
    let str_pregap = track.pregap |> Option.map (fun duration -> sprintf "\t%sPREGAP %s\n" cond_tab (Duration.string_of_duration duration) ) |> Option.value ~default: "" in
    let str_postgap = track.postgap |> Option.map (fun duration -> sprintf "\t%sPOSTGAP %s\n" cond_tab (Duration.string_of_duration duration) ) |> Option.value ~default: "" in
    let str_indexs = if track.indexs = [] then "" 
      else track.indexs |> List.map (fun (track_index, duration) -> sprintf "\t%sINDEX 0%d %s\n" (cond_tab) (track_index) (sum |> Option.map (Duration.duration_add duration) |> Option.value ~default: duration |> Duration.string_of_duration)) |> String.concat (sprintf "\n\t%s" (cond_tab)) in
    sprintf "%s%s%s%s%s%s%s\n" str_track str_cd_texts str_flags str_rem str_pregap str_postgap str_indexs


  let create_empty_track ~track = {
    track;
    flags = [];
    pregap = None;
    postgap = None;
    cd_texts = [];
    rems = Hashtbl.create 5;
    indexs = [];
  }
  
  let add_index (index, time) track = {
    track with indexs = track.indexs |> List.filter (fun (track_i, _) -> track_i <> index ) |> List.cons (index, Duration.to_min_sec_fra time)
  }

  let add_flag flag track = {
    track with flags = track.flags |> List.filter ( (<>) flag ) |> List.cons flag
  }

  let add_pregap duration track = {
    track with pregap = Some (Duration.to_min_sec_fra duration)
  }

  let add_prostgap duration track = {
    track with postgap = Some (Duration.to_min_sec_fra duration)
  } 

  let add_arranger arranger track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Arranger _ -> false | _ -> true ) |> List.cons (`Arranger arranger)
  }

  let add_composer composer track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Composer _ -> false | _ -> true ) |> List.cons (`Composer composer)
  } 

  let add_disc_id disc_id track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Disc_Id _ -> false | _ -> true ) |> List.cons (`Disc_Id disc_id)
  } 

  let add_genre genre track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Genre _ -> false | _ -> true ) |> List.cons (`Genre genre)
  } 

  let add_isrc isrc track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Isrc _ -> false | _ -> true ) |> List.cons (`Isrc isrc)
  } 

  let add_message message track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Message _ -> false | _ -> true ) |> List.cons (`Message message)
  } 

  let add_performer performer track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Performer _ -> false | _ -> true ) |> List.cons (`Performer performer)
  }

  let add_songwriter songwriter track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Songwriter _ -> false | _ -> true ) |> List.cons (`Songwriter songwriter)
  }
  
  let add_title title track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Title _ -> false | _ -> true ) |> List.cons (`Title title)
  } 

  let add_toc_info toc_info track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Toc_Info _ -> false | _ -> true ) |> List.cons (`Toc_Info toc_info)
  } 

  let add_toc_info2 disc_id track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Toc_Info2 _ -> false | _ -> true ) |> List.cons (`Toc_Info2 disc_id)
  }

  let add_size_info size_info track = {
    track with cd_texts = track.cd_texts |> List.filter ( function | `Size_Info _ -> false | _ -> true ) |> List.cons (`Size_Info size_info)
  }

  let add_rem (key, value) track = 
    Hashtbl.replace track.rems (key |> String.uppercase_ascii) value;
    track

  let update_index (index, new_duration) track = {
    track with indexs = track.indexs |> List.map ( fun (i, d) -> if i = index then (index, Duration.to_min_sec_fra new_duration) else (i, d) )
  }
end



module CueSheet = struct
  type cue_sheet = {
  catalog : string option;
  cd_text_file: string option;
  cd_texts : [
      `Arranger of string
    | `Composer of string
    | `Disc_Id of string
    | `Genre of string
    | `Message of string
    | `Performer of string
    | `Songwriter of string 
    | `Title of string
    | `Toc_Info of string
    | `Toc_Info2 of string
    | `Size_Info of string
    ] list;
  rems: (string, string) Hashtbl.t;
  file: (string*cue_file_format) option; 
  tracks: CueTrack.cue_track list
  }

  let create_empty_sheet = {
    catalog = None;
    cd_text_file = None;
    cd_texts = [];
    rems = Hashtbl.create 5;
    file = None;
    tracks = []
  }
  
  let add_catalog catalog sheet = {
    sheet with catalog = Some catalog
  }

  let add_cd_text_file cd_text_file sheet = {
    sheet with cd_text_file = Some cd_text_file
  }

  let add_arranger arranger sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Arranger _ -> false | _ -> true ) |> List.cons (`Arranger arranger)
  }

  let add_composer composer sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Composer _ -> false | _ -> true ) |> List.cons (`Composer composer)
  } 

  let add_disc_id disc_id sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Disc_Id _ -> false | _ -> true ) |> List.cons (`Disc_Id disc_id)
  } 

  let add_genre genre sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Genre _ -> false | _ -> true ) |> List.cons (`Genre genre)
  }

  let add_message message sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Message _ -> false | _ -> true ) |> List.cons (`Message message)
  } 

  let add_performer performer sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Performer _ -> false | _ -> true ) |> List.cons (`Performer performer)
  }

  let add_songwriter songwriter sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Songwriter _ -> false | _ -> true ) |> List.cons (`Songwriter songwriter)
  }
  
  let add_title title sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Title _ -> false | _ -> true ) |> List.cons (`Title title)
  } 

  let add_toc_info toc_info sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Toc_Info _ -> false | _ -> true ) |> List.cons (`Toc_Info toc_info)
  } 

  let add_toc_info2 disc_id sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Toc_Info2 _ -> false | _ -> true ) |> List.cons (`Toc_Info2 disc_id)
  }

  let add_size_info size_info sheet = {
    sheet with cd_texts = sheet.cd_texts |> List.filter ( function | `Size_Info _ -> false | _ -> true ) |> List.cons (`Size_Info size_info)
  }

  let add_rem (key, value) sheet = 
    Hashtbl.replace sheet.rems (key |> String.uppercase_ascii) value;
    sheet

  let add_file (filename, format) sheet = {
    sheet with file = Some (filename, format)
  }
  let add_track ( track: CueTrack.cue_track ) sheet = 
    let parameter_track_index, _ = track.track in
    {
      sheet with tracks = sheet.tracks |> List.filter (fun ({ track = (sheet_track_index, _); _ }: CueTrack.cue_track) -> sheet_track_index <> parameter_track_index ) |> List.cons track
    }
  
  let sort_track sheet = {
    sheet with tracks = sheet.tracks |> List.sort ( fun ({ track = (l_index, _); _ }: CueTrack.cue_track) ({ track = (r_index, _); _ }: CueTrack.cue_track)  -> compare l_index r_index)
  }

  
end


