(***********************************************************************)
(*                                                                     *)
(*                              CamlIDL                                *)
(*                                                                     *)
(*            Xavier Leroy, projet Cristal, INRIA Rocquencourt         *)
(*                                                                     *)
(*  Copyright 1999 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the Q Public License version 1.0                *)
(*                                                                     *)
(***********************************************************************)

(* $Id: structdecl.ml,v 1.15 2002-01-16 09:42:03 xleroy Exp $ *)

(* Handling of structure declarations *)

open Printf
open Utils
open Variables
open Idltypes
open Cvttyp
open Cvtval
open Struct

(* Convert an IDL struct declaration to an ML record declaration *)

let ml_declaration oc sd =
  if sd.sd_name = ""
  then fprintf oc "struct_%d = " sd.sd_stamp
  else fprintf oc "%s = " (String.uncapitalize sd.sd_name);
  match remove_dependent_fields sd.sd_fields with
    [f] ->
      fprintf oc "%a\n" out_ml_type f.field_typ
  | fields ->
      fprintf oc "{\n";
      List.iter
        (fun f ->
          fprintf oc "  %s: %a;\n"
                  (String.uncapitalize f.field_mlname)
                  out_ml_type f.field_typ)
        fields;
      fprintf oc "}\n"

(* Convert an IDL struct declaration to a C struct declaration *)

let c_declaration oc sd =
  if sd.sd_fields = []
  then fprintf oc "struct %s;\n" sd.sd_name
  else begin out_struct oc sd; fprintf oc ";\n\n" end

(* External (forward) declaration of the translation functions *)

let declare_transl oc sd =
  fprintf oc "extern void camlidl_ml2c_%s_struct_%s(value, struct %s *, camlidl_ctx _ctx);\n"
             sd.sd_mod sd.sd_name sd.sd_name;
  fprintf oc "extern value camlidl_c2ml_%s_struct_%s(struct %s *, camlidl_ctx _ctx);\n\n"
             sd.sd_mod sd.sd_name sd.sd_name

(* Translation function from an ML record to a C struct *)

let transl_ml_to_c oc sd =
  current_function := sprintf "struct %s" sd.sd_name;
  let v = new_var "_v" in
  let c = new_var "_c" in
  fprintf oc "void camlidl_ml2c_%s_struct_%s(value %s, struct %s * %s, camlidl_ctx _ctx)\n"
             sd.sd_mod sd.sd_name v sd.sd_name c;
  fprintf oc "{\n";
  let pc = divert_output() in
  increase_indent();
  struct_ml_to_c ml_to_c pc false Prefix.empty sd v (sprintf "(*%s)" c);
  output_variable_declarations oc;
  end_diversion oc;
  decrease_indent();
  fprintf oc "}\n\n";
  current_function := ""

(* Translation function from a C struct to an ML record *)

let transl_c_to_ml oc sd =
  current_function := sprintf "struct %s" sd.sd_name;
  let c = new_var "_c" in
  fprintf oc "value camlidl_c2ml_%s_struct_%s(struct %s * %s, camlidl_ctx _ctx)\n"
             sd.sd_mod sd.sd_name sd.sd_name c;
  fprintf oc "{\n";
  let pc = divert_output() in
  increase_indent();
  let v = new_ml_variable() in
  struct_c_to_ml c_to_ml pc Prefix.empty sd (sprintf "(*%s)" c) v;
  iprintf pc "return %s;\n" v;
  output_variable_declarations oc;
  end_diversion oc;
  decrease_indent();
  fprintf oc "}\n\n";
  current_function := ""

(* Emit the translation functions *)

let emit_transl oc sd =
  transl_ml_to_c oc sd;
  transl_c_to_ml oc sd

