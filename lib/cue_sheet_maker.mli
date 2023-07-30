(**********************************************************************************************)
(*                                                                                            *)
(*  Copyright (C) 2023 Yves Ndiaye                                                            *)
(*                                                                                            *)
(* This Source Code Form is subject to the terms of the Mozilla Public                        *)
(* License, v. 2.0. If a copy of the MPL was not distributed with this                        *)
(* file, You can obtain one at https://mozilla.org/MPL/2.0/.                                  *)
(*                                                                                            *)
(**********************************************************************************************)

(**
    Cue sheet maker is a library that allows to create cuesheet by given the necessary information

    {!cuesheet:CueSheet} is the main sub module of the library: It contains functions to handle the cuesheet

    {!cuetrack:CueTrack} contains functions to handle tracks described in the cuesheet

    {!duration:Duration} contains type to several forms of time representation
*)

module CueFileFormat : sig
  type t = BINARY | MOTOROLA | AIFF | WAVE | MP3

  val string_of_cue_format : t -> string
  val compare : t -> t -> int
end

module CueTrackMode : sig
  type t =
    | AUDIO
    | CDG
    | MODE1_2048
    | MODE1_2352
    | MODE2_2336
    | MODE2_2352
    | CDI_2336
    | CDI_2352

  val string_of_cue_track_mode : t -> string
  val compare : t -> t -> int
end

module CueTrackFlag : sig
  type t = PRE | DCP | F_4CH | SCMS

  val string_of_cue_flag : t -> string
  val compare : t -> t -> int
end

module Duration : sig
  type duration =
    [ `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ]

  val zero_frame : [> `MinSecFra of int * int * int ]
  (** Create a duration in the Minute Seconde Frame format with everything is set to 0*)

  val minute_seconde_format : min:int -> sec:int -> [> `MinSec of int * int ]
  (** Create a duration from the minutes and secondes*)

  val minute_seconde_millieme_format :
    min:int -> sec:int -> mil:int -> [> `MinSecMil of int * int * int ]
  (** Create a duration from the minutes, secondes and milliemes*)

  val minute_seconde_frame_format :
    min:int -> sec:int -> frame:int -> [> `MinSecFra of int * int * int ]
  (** Create a duration from the minutes, secondes and frames*)

  val to_min_sec_fra :
    [< `MinSec of 'a * 'b
    | `MinSecFra of 'a * 'b * int
    | `MinSecMil of 'a * 'b * int ] ->
    [> `MinSecFra of 'a * 'b * int ]
  (**Transform a duration to the MSF format*)

  val add :
    [< `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ] ->
    [< `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ] ->
    [> `MinSecFra of int * int * int ]

  val string_of_duration :
    [< `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ] ->
    string
  (** String representation of the duration in the MSF format*)
end

module CueTrack : sig
  type t

  val string_of_cue_track :
    ?tabulation:bool ->
    ?compute:
      [< `set of
         [< `MinSec of int * int
         | `MinSecFra of int * int * int
         | `MinSecMil of int * int * int ]
      | `sum of
        [< `MinSec of int * int
        | `MinSecFra of int * int * int
        | `MinSecMil of int * int * int ] ]
      option ->
    t ->
    string
  (** 
      String representation of a track in a cue sheet

      if [~tabulation] all lines in the string will be padding left by 2 spaces
      
      [~compute] indicates whether or not some operation must be apply to the indexes.
      [`set duration] override the indexes value of the track.
      [`sum duration] add duration to the existing time duration
    *)

  val create_empty_track : track:int * CueTrackMode.t -> t
  (**
      Create an track representation with just the track position in the album and its track mode
    *)

  val add_index :
    int
    * [< `MinSec of int * int
      | `MinSecFra of int * int * int
      | `MinSecMil of int * int * int ] ->
    t ->
    t
  (** Add a time index to the track. If the index already exist, the old value is replaced*)

  val add_flag : CueTrackFlag.t -> t -> t
  (** Add a flag to the track. If the flag already exist, the old value is replaced*)

  val add_pregap :
    [< `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ] ->
    t ->
    t
  (** Add a pregap to the track. If the pregap was already set, the old value is replaced*)

  val add_postgap :
    [< `MinSec of int * int
    | `MinSecFra of int * int * int
    | `MinSecMil of int * int * int ] ->
    t ->
    t
  (** Add a postgap to the track. If the postgap was already set, the old value is replaced*)

  val add_arranger : string -> t -> t
  (** Add an arranger to the track. If the arranger already exist, the old value is replaced*)

  val add_composer : string -> t -> t
  (** Add a composer to the track. If the composer already exist, the old value is replaced*)

  val add_disc_id : string -> t -> t
  (** Add a disc id to the track. If the disc id already exist, the old value is replaced*)

  val add_genre : string -> t -> t
  (** Add a genre to the track. If the genre already exist, the old value is replaced*)

  val add_isrc : string -> t -> t
  (** Add an isrc to the track. If the isrc already exist, the old value is replaced*)

  val add_message : string -> t -> t
  (** Add a message to the track. If the message already exist, the old value is replaced*)

  val add_performer : string -> t -> t
  (** Add a performer to the track. If the performer already exist, the old value is replaced*)

  val add_songwriter : string -> t -> t
  (** Add a songwritter to the track. If the songwritter already exist, the old value is replaced*)

  val add_title : string -> t -> t
  (** Add a title to the track. If the title already exist, the old value is replaced*)

  val add_toc_info : string -> t -> t
  (** Add a toc info to the track. If the toc info already exist, the old value is replaced*)

  val add_toc_info2 : string -> t -> t
  (** Add a toc info 2 to the track. If the toc info2 already exist, the old value is replaced*)

  val add_size_info : string -> t -> t
  (** Add a size info to the track. If the size info already exist, the old value is replaced*)

  val add_rem : string * string -> t -> t
  (** Add a rem to the track. If the rem key already exist, the old value is replaced. All key are set uppercase*)

  val update_index :
    int
    * [< `MinSec of int * int
      | `MinSecFra of int * int * int
      | `MinSecMil of int * int * int ] ->
    t ->
    t
  (** Update the time for a specific index. Do nothing if the index doesn't exist in the track indexes*)
end

module CueSheet : sig
  type t

  val create_empty_sheet : file:string * CueFileFormat.t -> t
  (**
      Create an cue sheet representation with just the file name and its format
    *)

  val string_of_cue_sheet : ?sum:bool -> t -> string
  (**
      String representation of a cue sheet

      if [~sum] all the indexes of tracks will be set by adding the offset time of previous tracks.
      Use [~sum] if you set for each track its length
    *)

  val add_catalog : string -> t -> t
  (** Add a catalog to the sheet. If the catalog already exist, the old value is replaced*)

  val add_cd_text_file : string -> t -> t
  (** Add a cd text file to the sheet. If the cd text file already exist, the old value is replaced*)

  val add_arranger : string -> t -> t
  (** Add an arraanger to the sheet. If the arranger already exist, the old value is replaced*)

  val add_composer : string -> t -> t
  (** Add a composer to the sheet. If the composer already exist, the old value is replaced*)

  val add_disc_id : string -> t -> t
  (** Add a disc id to the sheet. If the disc id already exist, the old value is replaced*)

  val add_genre : string -> t -> t
  (** Add a genre to the sheet. If the genre already exist, the old value is replaced*)

  val add_message : string -> t -> t
  (** Add a message to the sheet. If the message already exist, the old value is replaced*)

  val add_performer : string -> t -> t
  (** Add a performer to the sheet. If the performer already exist, the old value is replaced*)

  val add_songwriter : string -> t -> t
  (** Add a songwritter to the sheet. If the songwritter already exist, the old value is replaced*)

  val add_title : string -> t -> t
  (** Add a title to the sheet. If the title already exist, the old value is replaced*)

  val add_toc_info : string -> t -> t
  (** Add a toc info to the sheet. If the toc info already exist, the old value is replaced*)

  val add_toc_info2 : string -> t -> t
  (** Add a toc info 2 to the sheet. If the toc info 2 already exist, the old value is replaced*)

  val add_size_info : string -> t -> t
  (** Add a size info to the sheet. If the size info talog already exist, the old value is replaced*)

  val add_rem : string * string -> t -> t
  (** Add a rem to the sheet. If the rem key already exist, the old value is replaced. All key are set uppercase*)

  val add_track : CueTrack.t -> t -> t
  (** Add a track to the sheet. If the index of the track already exist, the old value is replaced*)

  val export : ?sum:bool -> string -> t -> (unit, exn) result
  (**
      Write the string representation of a cue sheet to the file [output]
      
      if [~sum] all the indexes of tracks will be set by adding the offset time of previous tracks.
      Use [~sum] if you set for each track its length

      See [string_of_cue_sheet]

      @return unit if sucess or exn if an error occured with the file handling
    *)
end
