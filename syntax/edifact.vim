" Vim syntax file
" Language:	EDIFACT Messages
" Maintainer:	Olivier Mengué <dolmen@users.sourceforge.net>
" Version:	1.0
" Last Change:	2004 Mar 22
" Copyright:	(c) 2004 Olivier Mengué

" Note:
"   If you want to colorize you own tags, just create a syntax
"   file that use the provided hook :
"     runtime! syntax/edifact.vim
"     syn keyword myedifactORG contained ORG
"     syn cluster edifactTagHook add=myedifactORG
"
"   Another hook is provided for data: edifactDataHook


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
syn match   edifactError contained /.\+$/

syn match   edifactEscape contained /?[?'+*:]/

syn match   edifactData contained /\([^?'+*:]\|?[?'+*:]\)\+/ contains=@edifactDataHook,edifactEscape nextgroup=@edifactSegmentData

syn match   edifactTag contained /[A-Z]\{3}/ contains=@edifactTagHook nextgroup=edifactQuote,edifactPlus

" End of Segment
syn match   edifactQuote contained /'/ nextgroup=edifactTag
" Separators
syn match   edifactColon contained /:/ nextgroup=@edifactSegmentData
syn match   edifactStar  contained /\*/ nextgroup=@edifactSegmentData
syn match   edifactPlus  contained /+/ nextgroup=@edifactSegmentData

syn cluster edifactSegmentData contains=edifactData,edifactPlus,edifactStar,edifactColon,edifactQuote

syn match   edifactMessage /^.*$/ contains=edifactError,edifactTag


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
  HiLink edifactTag         Keyword
  HiLink edifactQuote       Operator
  HiLink edifactPlus        Operator
  HiLink edifactStar        Operator
  HiLink edifactColon       Delimiter
  HiLink edifactEscape      Special
  HiLink edifactData        String
  HiLink edifactError       Error
  
  delcommand HiLink
endif

let b:current_syntax = "edifact"

" vim:ts=8:
