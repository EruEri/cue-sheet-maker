

type cue_file_format = BINARY | MOTOROLA | AIFF | WAVE | MP3

(** Transform the file format to its representation in the cue sheet*)
val string_of_cue_format : cue_file_format -> string
type cue_track_mode =
    AUDIO
  | CDG
  | MODE1_2048
  | MODE1_2352
  | MODE2_2336
  | MODE2_2352
  | CDI_2336
  | CDI_2352

(** Transform the track mode to its representation in the cue sheet*)
val string_of_cue_track_mode : cue_track_mode -> string
type cue_track_flag = PRE | DCP | F_4CH | SCMS

(** Transform the flag to its representation in the cue sheet*)
val string_of_cue_flag : cue_track_flag -> string
type cd_text =
    [ `Arranger of string
    | `Composer of string
    | `Disc_Id of string
    | `Genre of string
    | `Isrc of string
    | `Message of string
    | `Performer of string
    | `Size_Info of string
    | `Songwriter of string
    | `Title of string
    | `Toc_Info of string
    | `Toc_Info2 of string
    | `Upc_Ean of string ]
val string_of_cd_text :
  [< `Arranger of string
   | `Composer of string
   | `Disc_Id of string
   | `Genre of string
   | `Isrc of string
   | `Message of string
   | `Performer of string
   | `Size_Info of string
   | `Songwriter of string
   | `Title of string
   | `Toc_Info of string
   | `Toc_Info2 of string
   | `Upc_Ean of string ] ->
  string
module Duration :
  sig
    type duration =
        [ `MinSec of int * int
        | `MinSecFra of int * int * int
        | `MinSecMil of int * int * int ]

    (** Create a duration in the Minute Seconde Frame format with everything is set to 0*)
    val zero_frame : [> `MinSecFra of int * int * int ]

    (** Create a duration from the minutes and secondes*)
    val minute_seconde_format :
      min:int -> sec:int -> [> `MinSec of int * int ]

    (** Create a duration from the minutes, secondes and milliemes*)
    val minute_seconde_millieme_format :
      min:int -> sec:int -> mil:int -> [> `MinSecMil of int * int * int ]

    (** Create a duration from the minutes, secondes and frames*)
    val minute_seconde_frame_format :
      min:int -> sec:int -> frame:int -> [> `MinSecFra of int * int * int ]

    (**Transform a duration to the MSF format*)
    val to_min_sec_fra :
      [< `MinSec of 'a * 'b
       | `MinSecFra of 'a * 'b * int
       | `MinSecMil of 'a * 'b * int ] ->
      [> `MinSecFra of 'a * 'b * int ]
    val add :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      [> `MinSecFra of int * int * int ]

    (** String representation of the duration in the MSF format*)
    val string_of_duration :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      string
  end
module CueTrack :
  sig
    type cue_track = {
      track : int * cue_track_mode;
      flags : cue_track_flag list;
      pregap : [ `MinSecFra of int * int * int ] option;
      postgap : [ `MinSecFra of int * int * int ] option;
      cd_texts :
        [ `Arranger of string
        | `Composer of string
        | `Disc_Id of string
        | `Genre of string
        | `Isrc of string
        | `Message of string
        | `Performer of string
        | `Size_Info of string
        | `Songwriter of string
        | `Title of string
        | `Toc_Info of string
        | `Toc_Info2 of string ] list;
      rems : (string, string) Hashtbl.t;
      indexs : (int * [ `MinSecFra of int * int * int ]) list;
    }
    val string_of_cue_track :
      ?tabulation:bool ->
      ?compute:[< `set of
                    [< `MinSec of int * int
                     | `MinSecFra of int * int * int
                     | `MinSecMil of int * int * int ]
                | `sum of
                    [< `MinSec of int * int
                     | `MinSecFra of int * int * int
                     | `MinSecMil of int * int * int ] ]
               option ->
      cue_track -> string
    val create_empty_track : track:int * cue_track_mode -> cue_track
    val add_index :
      int *
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track
    val add_flag : cue_track_flag -> cue_track -> cue_track
    val add_pregap :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track
    val add_prostgap :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track
    val add_arranger : string -> cue_track -> cue_track
    val add_composer : string -> cue_track -> cue_track
    val add_disc_id : string -> cue_track -> cue_track
    val add_genre : string -> cue_track -> cue_track
    val add_isrc : string -> cue_track -> cue_track
    val add_message : string -> cue_track -> cue_track
    val add_performer : string -> cue_track -> cue_track
    val add_songwriter : string -> cue_track -> cue_track
    val add_title : string -> cue_track -> cue_track
    val add_toc_info : string -> cue_track -> cue_track
    val add_toc_info2 : string -> cue_track -> cue_track
    val add_size_info : string -> cue_track -> cue_track
    val add_rem : string * string -> cue_track -> cue_track
    val update_index :
      int *
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track
  end
module CueSheet :
  sig
    type cue_sheet = {
      catalog : string option;
      cd_text_file : string option;
      cd_texts :
        [ `Arranger of string
        | `Composer of string
        | `Disc_Id of string
        | `Genre of string
        | `Message of string
        | `Performer of string
        | `Size_Info of string
        | `Songwriter of string
        | `Title of string
        | `Toc_Info of string
        | `Toc_Info2 of string ] list;
      rems : (string, string) Hashtbl.t;
      file : string * cue_file_format;
      tracks : CueTrack.cue_track list;
    }
    val create_empty_sheet : file:string * cue_file_format -> cue_sheet
    val string_of_cue_sheet : ?sum:bool -> cue_sheet -> string
    val add_catalog : string -> cue_sheet -> cue_sheet
    val add_cd_text_file : string -> cue_sheet -> cue_sheet
    val add_arranger : string -> cue_sheet -> cue_sheet
    val add_composer : string -> cue_sheet -> cue_sheet
    val add_disc_id : string -> cue_sheet -> cue_sheet
    val add_genre : string -> cue_sheet -> cue_sheet
    val add_message : string -> cue_sheet -> cue_sheet
    val add_performer : string -> cue_sheet -> cue_sheet
    val add_songwriter : string -> cue_sheet -> cue_sheet
    val add_title : string -> cue_sheet -> cue_sheet
    val add_toc_info : string -> cue_sheet -> cue_sheet
    val add_toc_info2 : string -> cue_sheet -> cue_sheet
    val add_size_info : string -> cue_sheet -> cue_sheet
    val add_rem : string * string -> cue_sheet -> cue_sheet
    val add_file : string * cue_file_format -> cue_sheet -> cue_sheet
    val add_track : CueTrack.cue_track -> cue_sheet -> cue_sheet
  end
