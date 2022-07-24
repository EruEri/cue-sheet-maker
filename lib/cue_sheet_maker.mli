

type cue_file_format = BINARY | MOTOROLA | AIFF | WAVE | MP3

type cue_track_mode =
    AUDIO
  | CDG
  | MODE1_2048
  | MODE1_2352
  | MODE2_2336
  | MODE2_2352
  | CDI_2336
  | CDI_2352

type cue_track_flag = PRE | DCP | F_4CH | SCMS

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
      indexes : (int * [ `MinSecFra of int * int * int ]) list;
    }

    (** 
      String representation of a track in a cue sheet

      if [~tabulation] all lines in the string will be padding left by 2 spaces
      
      [~compute] indicates whether or not some operation must be apply to the indexes.
      [`set duration] override the indexes value of the track.
      [`sum duration] add duration to the existing time duration
    *)
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

    (**
      Create an track representation with just the track position in the album and its track mode
    *)
    val create_empty_track : track:int * cue_track_mode -> cue_track

    (** Add a time index to the track. If the index already exist, the old value is replaced*)
    val add_index :
      int *
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track

    (** Add a flag to the track. If the flag already exist, the old value is replaced*)
    val add_flag : cue_track_flag -> cue_track -> cue_track

    (** Add a pregap to the track. If the pregap was already set, the old value is replaced*)
    val add_pregap :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track

    (** Add a postgap to the track. If the postgap was already set, the old value is replaced*)
    val add_postgap :
      [< `MinSec of int * int
       | `MinSecFra of int * int * int
       | `MinSecMil of int * int * int ] ->
      cue_track -> cue_track

    (** Add an arranger to the track. If the arranger already exist, the old value is replaced*)
    val add_arranger : string -> cue_track -> cue_track

    (** Add a composer to the track. If the composer already exist, the old value is replaced*)
    val add_composer : string -> cue_track -> cue_track

    (** Add a disc id to the track. If the disc id already exist, the old value is replaced*)
    val add_disc_id : string -> cue_track -> cue_track

    (** Add a genre to the track. If the genre already exist, the old value is replaced*)
    val add_genre : string -> cue_track -> cue_track

    (** Add a isrc to the track. If the isrc already exist, the old value is replaced*)
    val add_isrc : string -> cue_track -> cue_track

    (** Add a message to the track. If the message already exist, the old value is replaced*)
    val add_message : string -> cue_track -> cue_track

    (** Add a performer to the track. If the performer already exist, the old value is replaced*)
    val add_performer : string -> cue_track -> cue_track

    (** Add a songwritter to the track. If the songwritter already exist, the old value is replaced*)
    val add_songwriter : string -> cue_track -> cue_track

    (** Add a title to the track. If the title already exist, the old value is replaced*)
    val add_title : string -> cue_track -> cue_track

    (** Add a toc info to the track. If the toc info already exist, the old value is replaced*)
    val add_toc_info : string -> cue_track -> cue_track

    (** Add a toc info 2 to the track. If the toc info2 already exist, the old value is replaced*)
    val add_toc_info2 : string -> cue_track -> cue_track

    (** Add a size info to the track. If the size info already exist, the old value is replaced*)
    val add_size_info : string -> cue_track -> cue_track

    (** Add a rem to the track. If the rem key already exist, the old value is replaced. All key are set uppercase*)
    val add_rem : string * string -> cue_track -> cue_track

    (** Update the time for a specific index. Do nothing if the index doesn't exist in the track indexes*)
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
