unit IMATH;

(*
  IMATH with OBJ link
  by Do-wan Kim.
  2010. 07. 
*)

{$DEFINE USE_IPRIME}
{$DEFINE USE_IMRAT}
{.$DEFINE USE_RSAMATH}

(*
  Name:     imath.h
  Purpose:  Arbitrary precision integer arithmetic routines.
  Author:   M. J. Fromberger <http://spinning-yarns.org/michael/>
  Info:     $Id: imath.h 635 2008-01-08 18:19:40Z sting $

  Copyright (C) 2002-2007 Michael J. Fromberger, All Rights Reserved.

  Permission is hereby granted, free of charge, to any person
  obtaining a copy of this software and associated documentation files
  (the "Software"), to deal in the Software without restriction,
  including without limitation the rights to use, copy, modify, merge,
  publish, distribute, sublicense, and/or sell copies of the Software,
  and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
 *)

interface

type
  mp_sign   = byte;
  mp_size   = longword;
  mp_result = integer;
  mp_small  = integer;
  mp_usmall = longword;
  mp_digit  = word;
  mp_word   = longword;

  pmp_small = ^mp_small;
  pmp_usmall = ^mp_usmall;
  
  mp_int = ^mpz_t;
  mpz_t = record
    single  : mp_digit;
    digits  : Pointer;  // dynamic array of mp_digit
    alloc   : mp_size;
    used    : mp_size;
    sign    : mp_sign;
  end;

(*
typedef struct mpz {
  mp_digit    single;
  mp_digit   *digits;
  mp_size     alloc;
  mp_size     used;
  mp_sign     sign;
} mpz_t, *mp_int;

#define MP_DIGITS(Z) ((Z)->digits)
#define MP_ALLOC(Z)  ((Z)->alloc)
#define MP_USED(Z)   ((Z)->used)
#define MP_SIGN(Z)   ((Z)->sign)

*)

const
  MP_OK     = 0;
  MP_FALSE  = 0;
  MP_TRUE   = -1;
  MP_MEMORY = -2;
  MP_RANGE  = -3;
  MP_UNDEF  = -4;
  MP_TRUNC  = -5;
  MP_BADARG = -6;
  MP_MINERR = -6;

  MP_NEG    = 1;
  MP_ZPOS   = 0;

(*
const mp_result MP_OK     = 0;  /* no error, all is well  */
const mp_result MP_FALSE  = 0;  /* boolean false          */
const mp_result MP_TRUE   = -1; /* boolean true           */
const mp_result MP_MEMORY = -2; /* out of memory          */
const mp_result MP_RANGE  = -3; /* argument out of range  */
const mp_result MP_UNDEF  = -4; /* result undefined       */
const mp_result MP_TRUNC  = -5; /* output truncated       */
const mp_result MP_BADARG = -6; /* invalid null argument  */
const mp_result MP_MINERR = -6;

const mp_sign   MP_NEG  = 1;    /* value is strictly negative */
const mp_sign   MP_ZPOS = 0;    /* value is non-negative      */

#define MP_DIGIT_BIT    (sizeof(mp_digit) * CHAR_BIT)
#define MP_WORD_BIT     (sizeof(mp_word) * CHAR_BIT)
#define MP_SMALL_MIN    LONG_MIN
#define MP_SMALL_MAX    LONG_MAX
#define MP_USMALL_MIN   ULONG_MIN
#define MP_USMALL_MAX   ULONG_MAX

#ifdef USE_LONG_LONG
#  ifndef ULONG_LONG_MAX
#    ifdef ULLONG_MAX
#      define ULONG_LONG_MAX   ULLONG_MAX
#    else
#      error "Maximum value of unsigned long long not defined!"
#    endif
#  endif
#  define MP_DIGIT_MAX   (ULONG_MAX * 1ULL)
#  define MP_WORD_MAX    ULONG_LONG_MAX
#else
#  define MP_DIGIT_MAX    (USHRT_MAX * 1UL)
#  define MP_WORD_MAX     (UINT_MAX * 1UL)
#endif

#define MP_MIN_RADIX    2
#define MP_MAX_RADIX    36

(* Values with fewer than this many significant digits use the
   standard multiplication algorithm; otherwise, a recursive algorithm
   is used.  Choose a value to suit your platform.


#define MP_MULT_THRESH  22

#define MP_DEFAULT_PREC 8   (* default memory allocation, in digits *)

(*
extern const mp_sign   MP_NEG;
extern const mp_sign   MP_ZPOS;

#define mp_int_is_odd(Z)  ((Z)->digits[0] & 1)
#define mp_int_is_even(Z) !((Z)->digits[0] & 1)

*)

function mp_int_is_odd(z : mp_int):boolean; cdecl;
function mp_int_is_even(z : mp_int):boolean; cdecl;

function mp_int_init(z : mp_int):mp_result; cdecl; external;
function mp_int_alloc:mp_int; cdecl; external;
function mp_int_init_size(z : mp_int; prec: mp_size):mp_result; cdecl; external;
function mp_int_init_copy(z,old : mp_int):mp_result; cdecl; external;
function mp_int_init_value(z : mp_int; value : mp_small):mp_result; cdecl; external;
function mp_int_set_value(z : mp_int; value : mp_small):mp_result; cdecl; external;
procedure mp_int_clear(z : mp_int); cdecl; external;
procedure mp_int_free(z : mp_int); cdecl; external;

function mp_int_copy(a, c : mp_int):mp_result; cdecl; external;           (* c = a     *)
procedure mp_int_swap(a, c : mp_int); cdecl; external;           (* swap a, c *)
procedure mp_int_zero(z : mp_int); cdecl; external;                    (* z = 0     *)
function mp_int_abs(a, c : mp_int):mp_result; cdecl; external;            (* c = |a|   *)
function mp_int_neg(a, c : mp_int):mp_result; cdecl; external;            (* c = -a    *)
function mp_int_add(a, b, c : mp_int):mp_result; cdecl; external;  (* c = a + b *)
function mp_int_add_value(a : mp_int; value : mp_small; c : mp_int):mp_result; cdecl; external;
function mp_int_sub(a, b, c : mp_int):mp_result; cdecl; external;  (* c = a - b *)
function mp_int_sub_value(a : mp_int; value : mp_small; c : mp_int):mp_result; cdecl; external;
function mp_int_mul(a, b, c : mp_int):mp_result; cdecl; external; (* c = a * b *)
function mp_int_mul_value(a : mp_int; value : mp_small; c : mp_int):mp_result; cdecl; external;
function mp_int_mul_pow2(a : mp_int; p2 : mp_small; c : mp_int):mp_result; cdecl; external;
function mp_int_sqr(a, c : mp_int):mp_result; cdecl; external;            (* c = a * a *)
function mp_int_div(a, b,             (* q = a / b *)
		     q, r : mp_int):mp_result; cdecl; external;           (* r = a % b *)
function mp_int_div_value(a : mp_int; value : mp_small; (* q = a / value *)
			   q : mp_int; r : pmp_small):mp_result; cdecl; external;   (* r = a % value *)
function mp_int_div_pow2(a : mp_int; p2 : mp_small;     (* q = a / 2^p2  *)
			  q, r : mp_int):mp_result; cdecl; external;       (* r = q % 2^p2  *)
function mp_int_mod(a, m, c : mp_int):mp_result; cdecl; external;  (* c = a % m *)
function mp_int_mod_value(a : mp_int; v : mp_small; r : pmp_small):mp_result; cdecl;
(* #define   mp_int_mod_value(A, V, R) mp_int_div_value((A), (V), 0, (R)) *)
function mp_int_expt(a : mp_int; b : mp_small; c : mp_int):mp_result; cdecl; external;         (* c = a^b *)
function mp_int_expt_value(a, b : mp_small; c : mp_int):mp_result; cdecl; external; (* c = a^b *)
function mp_int_expt_full(a, b, c : mp_int):mp_result; cdecl; external;     (* c = a^b *) // 1.15

function mp_int_compare(a, b : mp_int):Integer; cdecl; external;          (* a <=> b     *)
function mp_int_compare_unsigned(a, b : mp_int):Integer; cdecl; external; (* |a| <=> |b| *)
function mp_int_compare_zero(z : mp_int):Integer; cdecl; external;                  (* a <=> 0  *)
function mp_int_compare_value(z : mp_int; value : mp_small):Integer; cdecl; external; (* a <=> v  *)
function mp_int_compare_uvalue(z : mp_int; uv : mp_usmall):Integer; cdecl; external; (* a <=> uv *) // 1.17

(* Returns true if v|a, false otherwise (including errors) *)
function mp_int_divisible_value(a : mp_int; v : mp_small):Integer; cdecl; external;

(* Returns k >= 0 such that z = 2^k, if one exists; otherwise < 0 *)
function mp_int_is_pow2(z : mp_int):Integer; cdecl; external;

function mp_int_exptmod(a, b, m,
			 c : mp_int):mp_result; cdecl; external;                    (* c = a^b (mod m) *)
function mp_int_exptmod_evalue(a : mp_int; value : mp_small;
				m, c : mp_int):mp_result; cdecl; external;   (* c = a^v (mod m) *)
function mp_int_exptmod_bvalue(value : mp_small; b,
				m, c : mp_int):mp_result; cdecl; external;   (* c = v^b (mod m) *)
function mp_int_exptmod_known(a, b,
			       m, mu,
			       c : mp_int):mp_result; cdecl; external;              (* c = a^b (mod m) *)
function mp_int_redux_const(m, c : mp_int):mp_result; cdecl; external;

function mp_int_invmod(a, m, c : mp_int):mp_result; cdecl; external; (* c = 1/a (mod m) *)

function mp_int_gcd(a, b, c : mp_int):mp_result; cdecl; external;    (* c = gcd(a, b)   *)

function mp_int_egcd(a, b, c,    (* c = gcd(a, b)   *)
		      x, y : mp_int):mp_result; cdecl; external;            (* c = ax + by     *)

function mp_int_lcm(a, b, c : mp_int):mp_result; cdecl; external;    (* c = lcm(a, b)   *)

function mp_int_root(a : mp_int; b : mp_small; c : mp_int):mp_result; cdecl; external; (* c = floor(a^{1/b}) *)
function mp_int_sqrt(a, c : mp_int):mp_result; cdecl;
(* #define   mp_int_sqrt(a, c) mp_int_root(a, 2, c)       (* c = floor(sqrt(a)) *)

(* Convert to a small int, if representable; else MP_RANGE *)
function mp_int_to_int(z : mp_int; int_out : pmp_small):mp_result; cdecl; external;
function mp_int_to_uint(z : mp_int; uint_out : pmp_usmall):mp_result; cdecl; external;

(* Convert to nul-terminated string with the specified radix, writing at
   most limit characters including the nul terminator  *)
function mp_int_to_string(z : mp_int; radix : mp_size;
			   str : pAnsichar; limit : Integer):mp_result; cdecl; external;

(* Return the number of characters required to represent 
   z in the given radix.  May over-estimate. *)
function mp_int_string_len(z : mp_int; radix : mp_size):mp_result; cdecl; external;

(* Read zero-terminated string into z *)
function mp_int_read_string(z : mp_int; radix : mp_size; str : pAnsichar):mp_result; cdecl; external;
function mp_int_read_cstring(z : mp_int; radix : mp_size; str : pAnsichar;
			      str_end : ppAnsichar ):mp_result; cdecl; external;

(* Return the number of significant bits in z *)
function mp_int_count_bits(z : mp_int):mp_result; cdecl; external;

(* Convert z to two's complement binary, writing at most limit bytes *)
function mp_int_to_binary(z : mp_int; buf : Pointer; limit : Integer):mp_result; cdecl; external;

(* Read a two's complement binary value into z from the given buffer *)
function mp_int_read_binary(z : mp_int; buf : Pointer; len : Integer):mp_result; cdecl; external;

(* Return the number of bytes required to represent z in binary. *)
function mp_int_binary_len(z : mp_int):mp_result; cdecl; external;

(* Convert z to unsigned binary, writing at most limit bytes *)
function mp_int_to_unsigned(z : mp_int; buf : Pointer; limit : Integer):mp_result; cdecl; external;

(* Read an unsigned binary value into z from the given buffer *)
function mp_int_read_unsigned(z : mp_int; buf : Pointer; len : Integer):mp_result; cdecl; external;

(* Return the number of bytes required to represent z as unsigned output *)
function mp_int_unsigned_len(z : mp_int):mp_result; cdecl; external;

(* Return a statically allocated string describing error code res *)
function mp_error_string(res : mp_result):pAnsichar; cdecl; external;

(*
#if DEBUG
void      s_print(char *tag, mp_int z);
void      s_print_buf(char *tag, mp_digit *buf, mp_size num);
#endif

*)

{$IFDEF USE_IPRIME}
// iprime.h

(* Test whether z is likely to be prime
   MP_YES means it is probably prime
   MP_NO  means it is definitely composite
 *)
function mp_int_is_prime(z : mp_int):mp_result; cdecl; external;

(* Find the first apparent prime in ascending order from z *)
function mp_int_find_prime(z : mp_int):mp_result; cdecl; external;
{$ENDIF}

{$IFDEF USE_IMRAT}
// imrat.h

type
  mpq_t = record
    num : mpz_t;  (* Numerator         *)
    den : mpz_t;  (* Denominator, <> 0 *)
  end;
  mp_rat = ^mpq_t;

//typedef struct mpq {
//  mpz_t   num;    (* Numerator         *)
//  mpz_t   den;    (* Denominator, <> 0 *)
//} mpq_t, *mp_rat;

// mp_round_mode;
const
  MP_ROUND_DOWN       = 0;
  MP_ROUND_HALF_UP    = 1;
  MP_ROUND_UP         = 2;
  MP_ROUND_HALF_DOWN  = 3;

(* Rounding constants *)
(*
typedef enum {
  MP_ROUND_DOWN,
  MP_ROUND_HALF_UP,
  MP_ROUND_UP,
  MP_ROUND_HALF_DOWN
} mp_round_mode;
*)

function mp_rat_init(r : mp_rat):mp_result; cdecl; external;
function mp_rat_alloc:mp_rat; cdecl; external;
function mp_rat_init_size(r : mp_rat; n_prec, d_prec : mp_size):mp_result; cdecl; external;
function mp_rat_init_copy(r, old : mp_rat):mp_result; cdecl; external;
function mp_rat_set_value(r : mp_rat; numer, denom : Integer):mp_result; cdecl; external;
procedure mp_rat_clear(r : mp_rat); cdecl; external;
procedure mp_rat_free(r : mp_rat); cdecl; external;
function mp_rat_numer(r : mp_rat; z : mp_int):mp_result; cdecl; external;             (* z = num(r)  *)
function mp_rat_denom(r : mp_rat; z : mp_int):mp_result; cdecl; external;            (* z = den(r)  *)
function mp_rat_sign(r : mp_rat):mp_sign; cdecl; external;

function mp_rat_copy(a, c : mp_rat):mp_result; cdecl; external;              (* c = a       *)
procedure mp_rat_zero(r : mp_rat); cdecl; external;                        (* r = 0       *)
function mp_rat_abs(a, c : mp_rat):mp_result; cdecl; external;               (* c = |a|     *)
function mp_rat_neg(a, c : mp_rat):mp_result; cdecl; external;               (* c = -a      *)
function mp_rat_recip(a, c :  mp_rat):mp_result;cdecl; external;             (* c = 1 / a   *)
function mp_rat_add(a, b, c : mp_rat):mp_result; cdecl; external;    (* c = a + b   *)
function mp_rat_sub(a, b, c : mp_rat):mp_result; cdecl; external;     (* c = a - b   *)
function mp_rat_mul(a, b, c :  mp_rat):mp_result; cdecl; external;     (* c = a * b   *)
function mp_rat_div(a, b, c : mp_rat):mp_result; cdecl; external;     (* c = a / b   *)

function mp_rat_add_int(a : mp_rat; b : mp_int; c : mp_rat):mp_result; cdecl; external; (* c = a + b   *)
function mp_rat_sub_int(a : mp_rat; b : mp_int; c : mp_rat):mp_result; cdecl; external; (* c = a - b   *)
function mp_rat_mul_int(a : mp_rat; b : mp_int; c : mp_rat):mp_result; cdecl; external; (* c = a * b   *)
function mp_rat_div_int(a : mp_rat; b : mp_int; c : mp_rat):mp_result; cdecl; external; (* c = a / b   *)
function mp_rat_expt(a : mp_rat; b : mp_small; c : mp_rat):mp_result; cdecl; external;  (* c = a ^ b   *)

function mp_rat_compare(a, b : mp_rat):Integer; cdecl; external;           (* a <=> b     *)
function mp_rat_compare_unsigned(a, b : mp_rat):Integer; cdecl; external;  (* |a| <=> |b| *)
function mp_rat_compare_zero(r : mp_rat):Integer; cdecl; external;                (* r <=> 0     *)
function mp_rat_compare_value(r : mp_rat; n : mp_small; d : mp_small):Integer; cdecl; external; (* r <=> n/d *)
function mp_rat_is_integer(r : mp_rat):Integer; cdecl; external;

(* Convert to integers, if representable (returns MP_RANGE if not). *)
function mp_rat_to_ints(r : mp_rat; num, den : pmp_small):mp_result; cdecl; external;

(* Convert to nul-terminated string with the specified radix, writing
   at most limit characters including the nul terminator. *)
function mp_rat_to_string(r : mp_rat; radix : mp_size; str : pAnsichar; limit : Integer):mp_result; cdecl; external;

(* Convert to decimal format in the specified radix and precision,
   writing at most limit characters including a nul terminator. *)
function mp_rat_to_decimal(r : mp_rat; radix, prec : mp_size;
                            round_mode : Integer; str : pAnsichar; limit : Integer):mp_result; cdecl; external;

(* Return the number of characters required to represent r in the given
   radix.  May over-estimate. *)
function mp_rat_string_len(r : mp_rat; radix : mp_size):mp_result; cdecl; external;

(* Return the number of characters required to represent r in decimal
   format with the given radix and precision.  May over-estimate. *)
function mp_rat_decimal_len(r : mp_rat; radix, prec : mp_size):mp_result; cdecl; external;

(* Read zero-terminated string into r *)
function mp_rat_read_string(r : mp_rat; radix : mp_size; str : pAnsichar):mp_result; cdecl; external;
function mp_rat_read_cstring(r : mp_rat; radix : mp_size; str : pAnsichar;
			      str_end : ppAnsichar):mp_result; cdecl; external;
function mp_rat_read_ustring(r : mp_rat; radix : mp_size; str : pAnsichar;
			      str_end : ppAnsichar):mp_result; cdecl; external;

(* Read zero-terminated string in decimal format into r *)
function mp_rat_read_decimal(r : mp_rat; radix : mp_size; str : pAnsichar):mp_result; cdecl; external;
function mp_rat_read_cdecimal(r : mp_rat; radix : mp_size; str : pAnsichar;
			       str_end : ppAnsichar):mp_result; cdecl; external;
{$ENDIF}

{$IFDEF USE_RSAMATH}
(* Function to fill a buffer with nonzero random bytes *)
type
  TRSAMATHRandomFunc = procedure (buf : Pointer; Size : Integer); cdecl;
//typedef void (*random_f)(unsigned char *, int);

(* Convert integer to octet string, per PKCS#1 v.2.1 *)
function rsa_i2osp(z : mp_int; outbuf : Pointer; len : Integer):mp_result; cdecl; external;

(* Convert octet string to integer, per PKCS#1 v.2.1 *)
function rsa_os2ip(z : mp_int; inbuf : Pointer; len : Integer):mp_result; cdecl; external;

(* The following operations assume that you have converted your keys
   and message data into mp_int values somehow.                      *)

(* Primitive RSA encryption operation *)
function rsa_rsaep(msg, exp, mod_val, cipher : mp_int):mp_result; cdecl; external;

(* Primitive RSA decryption operation *)
function rsa_rsadp(cipher, exp, mod_val, msg : mp_int):mp_result; cdecl; external;

(* Primitive RSA signing operation *)
function rsa_rsasp(msg, exp, mod_val, signature : mp_int):mp_result; cdecl; external;

(* Primitive RSA verification operation *)
function rsa_rsavp(signature, exp, mod_val, msg : mp_int):mp_result; cdecl; external;

(* Compute the maximum length in bytes a message can have using PKCS#1
   v.1.5 encoding with the given modulus *)
function rsa_max_message_len(mod_val : mp_int):Integer; cdecl; external;

(* Encode a raw message per PKCS#1 v.1.5
   buf      - the buffer containing the message
   msg_len  - the length in bytes of the message
   buf_len  - the size in bytes of the buffer
   tag      - the message tag (nonzero byte)
   filler   - function to generate pseudorandom nonzero padding

   On input, the message is in the first msg_len bytes of the buffer;
   on output, the contents of the buffer are replaced by the padded
   message.  If there is not enough room, MP_RANGE is returned.
 *)
function rsa_pkcs1v15_encode(buf : Pointer; msg_len : Integer;
			      buf_len : Integer; tag : Integer; filler : TRSAMATHRandomFunc):mp_result; cdecl; external;

(* Decode a PKCS#1 v.1.5 message back to its raw form
   buf      - the buffer containing the encoded message
   buf_len  - the length in bytes of the buffer
   tag      - the expected message tag (nonzero byte)
   msg_len  - on output, receives the length of the message content

   On output, the message is packed into the first msg_len bytes of
   the buffer, and the rest of the buffer is zeroed.  If the buffer is
   not of the correct form, MP_UNDEF is returned and msg_len is undefined.
 *)
function rsa_pkcs1v15_decode(buf : Pointer; buf_len : Integer;
			      tag : Integer; msg_len : PInteger):mp_result; cdecl; external;

{$ENDIF}

implementation

uses SysUtils;

var
  __TurboFloat : LongBool = False;
  Dummy : Array[0..3] of Integer;

{$IFDEF USE_RSAMATH}
{$L RSAMATH.OBJ}
{$ENDIF}

{$IFDEF USE_IMRAT}
{$L IMRAT.OBJ}
{$ENDIF}

{$IFDEF USE_IPRIME}
{$L IPRIME.OBJ}
{$ENDIF}
  
{$L IMATH.OBJ}

function mp_int_is_odd(z:mp_int):boolean;
begin
  Result := Word(z.digits^) and 1 <> 0;
end;

function mp_int_is_even(z:mp_int):boolean;
begin
  Result := Word(z.digits^) and 1 = 0;
end;

function mp_int_mod_value(a : mp_int; v : mp_small; r : pmp_small):mp_result;
begin
  Result := mp_int_div_value(a, v, nil, r);
end;

function mp_int_sqrt(a, c : mp_int):mp_result;
begin
  Result := mp_int_root(a, 2, c);
end;

function malloc(Size : LongWord):Pointer; cdecl;
begin
  GetMem(Result,Size);
end;

function realloc(Mem: Pointer; Size: Longword): Pointer; cdecl;
begin
  ReallocMem(Mem, Size);
  Result := Mem;
end;

function memcpy(s1, s2 : Pointer; Size : LongWord):Pointer; cdecl;
begin
  System.Move(s2^,s1^,Size);
  Result := s1;
end;

procedure free(Mem : Pointer); cdecl;
begin
  FreeMem(Mem);
end;

function memset(Mem : Pointer; Val : Integer; Size : LongWord):Pointer; cdecl;
begin
  FillChar(Mem^,Size,Val);
  Result := Mem;
end;

function isSpace(c: char): LongBool; cdecl;
begin
  result := ord(c) <= 32;
end;

function isDigit(ch: char): LongBool; cdecl;
begin
  Result := ch in ['0'..'9'];
end;

function isAlpha(ch: char): LongBool; cdecl;
begin
  Result := ch in ['A'..'Z','a'..'z'];
end;

function strlen(str : Pointer):LongWord; cdecl;
begin
  Result := SysUtils.StrLen(str);
end;

function _ftol: Integer; cdecl;
var
  F: double;
begin
  asm
    lea    eax, F
    fstp  qword ptr [eax]
  end;
  Result := Trunc(F);
end;

function _ltoupper(C: Integer): Integer; cdecl;
begin
  Result := Integer(UpperCase(Chr(C)));
end;

{$IFDEF USE_RSAMATH}
function memmove(s1, s2 : Pointer; n : Longword):Pointer; cdecl;
begin
  System.Move(s2^,s1^, n);
  Result := s1;
end;
{$ENDIF} 


end.

