" Vim syntax file
" Language:	UN/EDIFACT Messages
" Maintainer:	Olivier Mengué <dolmen@users.sourceforge.net>
" Version:	2.0
" Last Change:	2004 Mar 22

" Note:
"   This syntax script colorizes files that contains *only* EDIFACT
"   messages. This means that non-EDIFACT text will be colored as Error.
"
"   If you want to colorize you own tags, just create a syntax
"   file that use the provided hooks (add syntax header/footer):
"     runtime! syntax/edifact.vim
"     unlet b:current_syntax
"     syn keyword myedifactORG contained ORG
"     syn cluster edifactTagHook add=myedifactORG
"   If you want to add EDIFACT messages parsing to your syntax file
"   inside parentheses:
"     syn include syntax/edifact.vim
"     syn match  mysyntaxSpecial /[()]/
"     syn region mysyntaxEdifact matchgroup=mysyntaxSpecial keepend
"        \ start=/(/ end=/^)$/ contains=edifactError,edifactSegment
"   A sample segment (TXT) is defined here.
"
"   Another hook is provided for data: edifactDataHook
"
" Change Log:
"   2004-03-21	Initial version. Release on vim.org.
"   2004-03-25  Improved error reporting to ease editing:
"		- unclosed segments
"		- invalid text between segments
"		- error stops at the next quote, which may be just before
"		  the beginning of a valid segment
"		Renamed edifactStar  to edifactAsterisk,
"		        edifactQuote to edifactApostrophe
"		to use the same terms as in the standard
"		(http://www.unece.org/trade/untdid/texts/d422_d.htm)
"		Improved grammar with @edifactSegmentHook to plug more
"		specific segment definition.
"		Added 'keepend' to edifactSegment.
"		Added sample parsing for TXT segment.
"		Did tests of derived syntax reusing this syntax.
"
"
" References:
"   http://www.gefeg.com/jswg/v41/data/V41-9735-1.pdf
"   http://www.gefeg.com/jswg/v41/se/sl1.htm
"   http://www.unece.org/trade/untdid/texts/d422_d.htm




" Copyright:	(c) 2004 Olivier Mengué
" Licence:
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:

"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.

"   THE SOFTWARE IS PROVIDED "AS IS", AND COPYRIGHT HOLDERS MAKE NO
"   REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT
"   LIMITED TO, WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
"   PURPOSE OR THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT
"   INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
"   RIGHTS. COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT,
"   SPECIAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF ANY USE OF THE
"   SOFTWARE OR DOCUMENTATION.
"
"   Except as contained in this notice, the name of a copyright holder shall
"   not be used in advertising or otherwise to promote the sale, use or
"   other dealings in this Software without prior written authorization of
"   the copyright holder.



" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Edifact is for uppercase lovers
syn case match
setlocal iskeyword=A-Z

" Any char outside of a closed segment 
syn match   edifactError contained /'\|\([^']\|?'\)\+/

syn match   edifactEscape contained /?[?'+*:]/

syn match   edifactData contained /\([^?'+*:]\|?[?'+*:]\)\+/ contains=@edifactDataHook,edifactEscape nextgroup=@edifactSegmentData

syn match   edifactTag contained /[A-Z]\{3}/ contains=@edifactTagHook nextgroup=edifactError,edifactApostrophe,edifactPlusSignNG

" End of Segment
syn match   edifactApostrophe contained /'/
" Separators
syn match   edifactColon      contained /:/
syn match   edifactAsterisk   contained /\*/
syn match   edifactPlusSign   contained /+/
" For generic segments
syn match   edifactPlusSignNG contained /+/ contains=edifactPlusSign nextgroup=@edifactSegmentData

syn match   edifactSeparator  contained /[:*+]/ contains=edifactPlusSign,edifactAsterisk,edifactColon nextgroup=@edifactSegmentData

syn cluster edifactSegmentData contains=edifactData,edifactSeparator,edifactApostrophe



" Sample segment : TXT Segment
syn match  edifactTXT contained /TXT+/me=e-1 nextgroup=edifactError,edifactTXT0077
" TXT.0077  Text reference code   [an3]
" I'm not sure about definition of an: which special chars are allowed?
" Maybe the answer is in ISO 2382/4
syn match  edifactTXT0077 contained /+[A-Za-z0-9]\{3}/hs=s+1 contains=edifactPlusSign nextgroup=edifactError,edifactTXT0078,edifactApostrophe
" TXT.0078  Free form text        [an..70]
syn match  edifactTXT0078 contained /+\([A-Za-z]\|?[?'+*:]\)\{,70}/hs=s+1 contains=edifactPlusSign,edifactEscape nextgroup=edifactError,edifactApostrophe
" Finally plug the definition
syn cluster edifactSegmentHook add=edifactTXT



" The segment definition
" Plug your own segments using edifactSegmentHook
syn region  edifactSegment contained start=/\<[A-Z]\{3}+\?/ skip=/?'/ end=/'/ oneline contains=edifactError,edifactTag,@edifactSegmentHook keepend 

" Top level syntax entry
" This defines that the buffer contains only EDIFACT segments
syn match   edifactMessageLine /^.*$/ contains=edifactError,edifactSegment


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_asm_syntax_inits")
  if version < 508
    let did_edifact_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  " Uncolored segment is an error, but we have a c
  "HiLink edifactSegment     edifactError
  HiLink edifactTag         Keyword
  HiLink edifactApostrophe  Operator
  HiLink edifactPlusSign    Operator
  HiLink edifactAsterisk    Operator
  HiLink edifactColon       Delimiter
  HiLink edifactEscape      Special
  HiLink edifactData        String
  HiLink edifactError       Error

  HiLink edifactTXT         Underlined
  HiLink edifactTXT0077     Underlined
  HiLink edifactTXT0078     Underlined
  delcommand HiLink
endif

let b:current_syntax = "edifact"

" vim:ts=8:sts=4:sw=2:
