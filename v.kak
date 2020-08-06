# https://vlang.io/
#
# https://github.com/vlang/v/blob/8d9f38f67034d4782bb13d5aa9c7dcd46b09366f/doc/docs.md#appendix-i-keywords
#

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*(\.v|\.vv|\.vsh) %{
    set-option buffer filetype v
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=v %{
}

hook -group v-highlight global WinSetOption filetype=v %{
    add-highlighter window/v ref v
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/v }
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/v regions
add-highlighter shared/v/code default-region group
add-highlighter shared/v/back_string region '`' '`' fill string
add-highlighter shared/v/double_string region '"' (?<!\\)(\\\\)*" fill string
add-highlighter shared/v/single_string region "'" (?<!\\)(\\\\)*' fill string
add-highlighter shared/v/comment region /\* \*/ fill comment
add-highlighter shared/v/comment_line region '//' $ fill comment

add-highlighter shared/v/code/ regex %{-?([0-9]*\.(?!0[xX]))?\b([0-9]+|0[xX][0-9a-fA-F]+)\.?([eE][+-]?[0-9]+)?i?\b} 0:value

evaluate-commands %sh{
    # Grammar
    keywords='as assert break const continue defer else enum fn for go goto if import
    		  in interface is match module mut or pub return struct type unsafe'
    types='bool
    	   string
    	   i8 i16 int i64 i128
		   byte u16 u32 u64 u128
		   rune
    	   f32 f64
    	   any_int any_float
    	   byteptr voidptr charptr size_t
    	   any'
    values='false true none'
    functions='error panic print println'

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list v_static_words $(join "${keywords} ${types} ${values} ${functions}" ' ')"

    # Highlight keywords
    printf %s "
        add-highlighter shared/v/code/ regex \b($(join "${keywords}" '|'))\b 0:keyword
        add-highlighter shared/v/code/ regex \b($(join "${types}" '|'))\b 0:type
        add-highlighter shared/v/code/ regex \b($(join "${values}" '|'))\b 0:value
        add-highlighter shared/v/code/ regex \b($(join "${functions}" '|'))\b 0:builtin
    "
}

