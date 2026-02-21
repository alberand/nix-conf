""
" Name:        alabaster-dark.vim
" Description: Dark variant with muted colors for comfortable night coding.
"              Inspired by tonsky's Alabaster theme.
" Maintainer:  sderev
" License:     MIT
"""

" ============================================================================
" COLOR PALETTE
" ============================================================================

" Base backgrounds
let s:bg_main        = '#0e1415'   " cterm: 233 - Very dark blue-black
let s:bg_highlight   = '#1a1f20'   " cterm: 234 - Subtle highlight
let s:bg_dark        = '#293334'   " cterm: 236 - Dark grey-green (selection)

" Foreground colors
let s:fg_main        = '#cecece'   " cterm: 252 - Light grey (main text)
let s:fg_grey        = '#708b8d'   " cterm: 66  - Blue-grey (punctuation)
let s:fg_grey_dim    = '#505050'   " cterm: 239 - Dim grey (less important)

" Semantic colors (muted for dark background)
let s:gold           = '#cd974b'   " cterm: 179 - Warm gold (cursor, highlights)
let s:yellow_beige   = '#dfdf8e'   " cterm: 186 - Yellow-beige (comments)
let s:green_muted    = '#95cb82'   " cterm: 114 - Muted green (strings)
let s:pink_muted     = '#cc8bc9'   " cterm: 182 - Muted pink/purple (constants)
let s:blue_light     = '#71ade7'   " cterm: 110 - Light blue (definitions, functions)
let s:blue_bright    = '#00d7ff'   " cterm: 45  - Bright blue (links, special)

" ============================================================================
" HELPER FUNCTION
" ============================================================================

function! s:HL(group, fg, bg, ctermfg, ctermbg)
  let l:cmd = 'hi ' . a:group . ' guisp=NONE'
  if a:fg != ''
    let l:cmd .= ' guifg=' . a:fg
  endif
  if a:bg != ''
    let l:cmd .= ' guibg=' . a:bg
  endif
  if a:ctermfg != ''
    let l:cmd .= ' ctermfg=' . a:ctermfg
  endif
  if a:ctermbg != ''
    let l:cmd .= ' ctermbg=' . a:ctermbg
  endif
  let l:cmd .= ' gui=NONE cterm=NONE'
  execute l:cmd
endfunction

" ============================================================================
" VIM INITIALIZATION
" ============================================================================

set background=dark
hi clear

if exists('syntax_on')
    syntax reset
endif

let g:colors_name='alabaster-dark'
set t_Co=256

" ============================================================================
" UI ELEMENTS
" ============================================================================

call s:HL('ColorColumn',      s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('Conceal',          s:fg_main,      s:bg_main,       '252', '233')
call s:HL('Cursor',           s:bg_main,      s:gold,          '233', '179')
call s:HL('lCursor',          s:bg_main,      s:gold,          '233', '179')
call s:HL('CursorIM',         s:bg_main,      s:gold,          '233', '179')
call s:HL('CursorColumn',     '',             s:bg_highlight,  '',    '234')
call s:HL('CursorLine',       '',             s:bg_highlight,  '',    '234')
call s:HL('Directory',        s:blue_light,   '',              '110', '')
call s:HL('DiffAdd',          s:bg_main,      s:green_muted,   '233', '114')
call s:HL('DiffChange',       s:bg_main,      s:blue_light,    '233', '110')
call s:HL('DiffDelete',       s:bg_main,      s:pink_muted,    '233', '182')
call s:HL('DiffText',         s:bg_main,      s:gold,          '233', '179')
call s:HL('EndOfBuffer',      s:fg_grey_dim,  '',              '239', '')
call s:HL('ErrorMsg',         s:fg_main,      s:pink_muted,    '252', '182')
call s:HL('VertSplit',        s:fg_grey,      s:bg_main,       '66',  '233')
call s:HL('Folded',           s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('FoldColumn',       s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('SignColumn',       s:fg_grey,      s:bg_main,       '66',  '233')
call s:HL('IncSearch',        s:bg_main,      s:gold,          '233', '179')
call s:HL('LineNr',           s:fg_grey,      s:bg_main,       '66',  '233')
call s:HL('LineNrAbove',      s:fg_grey_dim,  '',              '239', '')
call s:HL('LineNrBelow',      s:fg_grey_dim,  '',              '239', '')
call s:HL('CursorLineNr',     s:gold,         '',              '179', '')
call s:HL('MatchParen',       s:gold,         s:bg_dark,       '179', '236')
call s:HL('ModeMsg',          s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('MoreMsg',          s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('NonText',          s:fg_grey_dim,  s:bg_main,       '239', '233')
call s:HL('Pmenu',            s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('PmenuSel',         s:bg_main,      s:gold,          '233', '179')
call s:HL('PmenuSbar',        s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('PmenuThumb',       s:bg_main,      s:gold,          '233', '179')
call s:HL('Question',         s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('QuickFixLine',     s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('Search',           s:bg_main,      s:gold,          '233', '179')
call s:HL('SpecialKey',       s:blue_light,   '',              '110', '')
call s:HL('SpellBad',         s:pink_muted,   '',              '252', '182')
call s:HL('SpellCap',         s:fg_main,      '',              '252', '110')
call s:HL('SpellLocal',       s:fg_main,      '',              '252', '114')
call s:HL('SpellRare',        s:fg_main,      '',              '252', '179')
call s:HL('StatusLine',       s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('StatusLineNC',     s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('StatusLineTerm',   s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('StatusLineTermNC', s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('TabLine',          s:fg_main,      s:bg_dark,       '252', '236')
call s:HL('TabLineFill',      s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('TabLineSel',       s:bg_main,      s:gold,          '233', '179')
call s:HL('Terminal',         s:fg_main,      s:bg_main,       '252', '233')
call s:HL('Title',            s:blue_light,   '',              '110', '')
call s:HL('Visual',           '',             s:bg_dark,       '',    '236')
call s:HL('VisualNOS',        s:fg_grey,      s:bg_dark,       '66',  '236')
call s:HL('WarningMsg',       s:gold,         s:bg_dark,       '179', '236')
call s:HL('WildMenu',         s:bg_main,      s:gold,          '233', '179')

" Modern Neovim UI groups (Neovim 0.4+)
call s:HL('NormalFloat',      s:fg_main,      s:bg_highlight,  '252', '234')
call s:HL('FloatBorder',      s:fg_grey,      s:bg_highlight,  '66',  '234')
call s:HL('NormalNC',         s:fg_main,      s:bg_main,       '252', '233')
call s:HL('Whitespace',       s:fg_grey_dim,  '',              '239', '')

" LSP Diagnostic groups (Neovim 0.6+)
call s:HL('DiagnosticError',  s:pink_muted,   '',              '182', '')
call s:HL('DiagnosticWarn',   s:gold,         '',              '179', '')
call s:HL('DiagnosticInfo',   s:blue_light,   '',              '110', '')
call s:HL('DiagnosticHint',   s:fg_grey,      '',              '66',  '')
call s:HL('DiagnosticOk',     s:green_muted,  '',              '114', '')

" ============================================================================
" SYNTAX HIGHLIGHTING - MAJOR GROUPS
" ============================================================================

call s:HL('Normal',     s:fg_main,      s:bg_main, '252', '233')
call s:HL('Comment',    s:yellow_beige, '',        '186', '')
call s:HL('Constant',   s:pink_muted,   '',        '182', '')
call s:HL('Identifier', s:blue_light,   '',        '110', '')
call s:HL('Statement',  s:fg_main,      '',        '252', '')
call s:HL('PreProc',    s:fg_main,      '',        '252', '')
call s:HL('Type',       s:fg_main,      '',        '252', '')
call s:HL('Special',    s:fg_main,      '',        '252', '')
call s:HL('Underlined', s:blue_bright,  '',        '45',  '')
call s:HL('Ignore',     s:fg_grey_dim,  '',        '239', '')
call s:HL('Error',      s:fg_main,      s:pink_muted, '252', '182')
call s:HL('Todo',       s:bg_main,      s:green_muted, '233', '114')

" ============================================================================
" SYNTAX HIGHLIGHTING - MINOR GROUPS
" ============================================================================

call s:HL('String',         s:green_muted,  '', '114', '')
call s:HL('Character',      s:green_muted,  '', '114', '')
call s:HL('Number',         s:pink_muted,   '', '182', '')
call s:HL('Boolean',        s:pink_muted,   '', '182', '')
call s:HL('Float',          s:pink_muted,   '', '182', '')
call s:HL('Function',       s:blue_light,   '', '110', '')
call s:HL('Conditional',    s:fg_main,      '', '252', '')
call s:HL('Repeat',         s:fg_main,      '', '252', '')
call s:HL('Label',          s:fg_main,      '', '252', '')
call s:HL('Operator',       s:fg_main,      '', '252', '')
call s:HL('Keyword',        s:pink_muted,   '', '182', '')
call s:HL('Exception',      s:fg_main,      '', '252', '')
call s:HL('Include',        s:fg_main,      '', '252', '')
call s:HL('Define',         s:blue_light,   '', '110', '')
call s:HL('Macro',          s:fg_main,      '', '252', '')
call s:HL('PreCondit',      s:fg_main,      '', '252', '')
call s:HL('StorageClass',   s:fg_main,      '', '252', '')
call s:HL('Structure',      s:fg_main,      '', '252', '')
call s:HL('Typedef',        s:fg_main,      '', '252', '')
call s:HL('SpecialChar',    s:green_muted,  '', '114', '')
call s:HL('Tag',            s:blue_bright,  '', '45',  '')
call s:HL('Delimiter',      s:fg_grey,      '', '66',  '')
call s:HL('SpecialComment', s:yellow_beige, '', '186', '')
call s:HL('Debug',          s:fg_main,      '', '252', '')

" ============================================================================
" CUSTOM SYNTAX - BRACKETS AND DELIMITERS
" ============================================================================
" Enhanced highlighting for brackets and delimiters.
" By default, applies to programming languages only (not text files like markdown).
" Users can customize by setting g:alabaster_dark_prog_languages.
" Set to empty string '' to apply to ALL filetypes.
" Example: let g:alabaster_dark_prog_languages = 'python,javascript,rust'

" Default programming language list
let s:default_prog_languages = 'bash,c,cpp,css,go,html,java,javascript,php,python,ruby,rust,sh,shell,typescript'

" Allow user customization via g:alabaster_dark_prog_languages
if !exists('g:alabaster_dark_prog_languages')
    let g:alabaster_dark_prog_languages = s:default_prog_languages
endif

function! s:ApplyBracketsAndDelimiters()
    " Apply to all languages if empty, otherwise check if current filetype is in the list
    if g:alabaster_dark_prog_languages == '' || index(split(g:alabaster_dark_prog_languages, ','), &filetype) >= 0
        syntax match Brackets "[\[\]{}()]"
        syntax match Delimiters "[;]"
        execute 'highlight Brackets guifg=' . s:fg_grey . ' ctermfg=66'
        execute 'highlight Delimiters guifg=' . s:fg_grey . ' ctermfg=66'
    endif
endfunction

" Apply on all FileType events
augroup alabaster_dark_custom_syntax
    autocmd!
    autocmd FileType * call s:ApplyBracketsAndDelimiters()
augroup END

" Apply immediately if current buffer has a filetype
if &filetype != ''
    call s:ApplyBracketsAndDelimiters()
endif

" ============================================================================
" LANGUAGE-SPECIFIC OVERRIDES
" ============================================================================

" ----------------------------------------------------------------------------
" Python
" ----------------------------------------------------------------------------

execute 'hi pythonBoolean guifg=' . s:pink_muted . ' ctermfg=182'
execute 'hi pythonConstant guifg=' . s:pink_muted . ' ctermfg=182'
execute 'hi pythonFunction guifg=' . s:blue_light . ' ctermfg=110 guibg=NONE ctermbg=NONE'
execute 'hi pythonQuotes guifg=' . s:fg_grey . ' ctermfg=66'
execute 'hi pythonTripleQuotes guifg=' . s:yellow_beige . ' ctermfg=186'
execute 'hi pythonBuiltin guifg=' . s:fg_main . ' ctermfg=252'

" Assign False, True, and None keywords from pythonBuiltin to pythonConstant.
" Function ensures consistent application when opening Python files or sourcing .vimrc.
function! s:ApplyCustomPythonColors()
    syn keyword pythonConstant False True None
endfunction

augroup alabaster_dark_python_colors
    autocmd!
    autocmd FileType python call s:ApplyCustomPythonColors()
augroup END

call s:ApplyCustomPythonColors()

" ----------------------------------------------------------------------------
" reStructuredText (reST)
" ----------------------------------------------------------------------------
" Commonly used for documentation (Sphinx, Python docs)

" Document Structure
execute 'hi rstSections guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'
execute 'hi rstTransition guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'

" Code & Literals
execute 'hi rstInlineLiteral guifg=' . s:blue_light . ' guibg=' . s:bg_dark . ' ctermfg=110 ctermbg=236'
execute 'hi rstLiteralBlock guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'
execute 'hi rstCodeBlock guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'
execute 'hi rstDoctestBlock guifg=' . s:pink_muted . ' guibg=NONE ctermfg=182 ctermbg=NONE'

" Directives (.. note::, .. warning::, etc.)
execute 'hi rstDirective guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'
execute 'hi rstExDirective guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'

" Links & References
execute 'hi rstInterpretedTextOrHyperlinkReference guifg=' . s:blue_light . ' guibg=' . s:bg_dark . ' ctermfg=110 ctermbg=236'
execute 'hi rstStandaloneHyperlink guifg=' . s:blue_bright . ' guibg=NONE ctermfg=45 ctermbg=NONE'
execute 'hi rstHyperlinkTarget guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'
execute 'hi rstHyperlinkReference guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'

" Citations & Footnotes
execute 'hi rstFootnote guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'
execute 'hi rstFootnoteReference guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'
execute 'hi rstCitation guifg=' . s:green_muted . ' guibg=NONE ctermfg=114 ctermbg=NONE'
execute 'hi rstCitationReference guifg=' . s:blue_light . ' guibg=NONE ctermfg=110 ctermbg=NONE'

" Text Formatting
execute 'hi rstEmphasis guifg=' . s:fg_main . ' ctermfg=252'
execute 'hi rstStrongEmphasis guifg=' . s:fg_main . ' gui=bold cterm=bold ctermfg=252'

" Special Elements
execute 'hi rstTodo guifg=' . s:bg_main . ' guibg=' . s:green_muted . ' ctermfg=233 ctermbg=114'
execute 'hi rstDelimiter guifg=' . s:fg_grey . ' guibg=NONE ctermfg=66 ctermbg=NONE'

" ----------------------------------------------------------------------------
" C/C++
" ----------------------------------------------------------------------------

execute 'hi cppConstant guifg=' . s:pink_muted . ' ctermfg=182 guibg=NONE ctermbg=NONE'
execute 'hi cFunction guifg=' . s:blue_light . ' ctermfg=110 guibg=NONE ctermbg=NONE'

" ----------------------------------------------------------------------------
" Markdown
" ----------------------------------------------------------------------------

execute 'hi markdownItalicDelimiter guifg=' . s:yellow_beige . ' ctermfg=186'
execute 'hi markdownBlockquote guifg=' . s:green_muted . ' ctermfg=114'
execute 'hi markdownBold guifg=' . s:fg_main . ' ctermfg=252'
execute 'hi markdownBoldDelimiter guifg=' . s:fg_grey . ' ctermfg=66'
execute 'hi markdownCode guifg=' . s:blue_light . ' ctermfg=110 guibg=' . s:bg_dark . ' ctermbg=236'
execute 'hi markdownCodeDelimiter guifg=' . s:fg_grey . ' ctermfg=66'
execute 'hi markdownFootnote guifg=' . s:pink_muted . ' ctermfg=182'
execute 'hi markdownHeadingDelimiter guifg=' . s:blue_light . ' ctermfg=110'
execute 'hi markdownItalic guifg=' . s:fg_main . ' ctermfg=252'
execute 'hi markdownLinkDelimiter guifg=' . s:pink_muted . ' ctermfg=182'
execute 'hi markdownListMarker guifg=' . s:gold . ' ctermfg=179'
execute 'hi markdownOrderedListMarker guifg=' . s:gold . ' ctermfg=179'
execute 'hi markdownLinkText guifg=' . s:fg_main . ' ctermfg=252'

" ----------------------------------------------------------------------------
" Bash/Shell
" ----------------------------------------------------------------------------

execute 'hi shComment guifg=' . s:yellow_beige . ' ctermfg=186'
execute 'hi shString guifg=' . s:green_muted . ' ctermfg=114'
execute 'hi shFunction guifg=' . s:blue_light . ' ctermfg=110'

" ----------------------------------------------------------------------------
" Go
" ----------------------------------------------------------------------------

execute 'hi goDeclaration guifg=' . s:fg_main . ' ctermfg=252'
execute 'hi goFunction guifg=' . s:blue_light . ' ctermfg=110'

" ----------------------------------------------------------------------------
" LaTeX
" ----------------------------------------------------------------------------

execute 'hi texTitleArg guifg=' . s:blue_light . ' ctermfg=110'
execute 'hi texStyleItal guifg=' . s:fg_main . ' ctermfg=252'

" ----------------------------------------------------------------------------
" Llama.vim
" ----------------------------------------------------------------------------

execute 'hi llama_hl_hint guifg=' . s:fg_grey . ' ctermfg=66'
execute 'hi llama_hl_info guifg=' . s:blue_light . ' ctermfg=110'
