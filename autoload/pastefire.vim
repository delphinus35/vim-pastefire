" Vim glbal plugin for Pastefire (http://pastefire.com/)
" Last Change: 2012 Feb 09
" Maintainer: delphinus <delphinus@remora.cx>
" License: This file is placed in th public domain.

let s:save_cpo = &cpo
set cpo&vim

function! pastefire#run(str, line1, line2)
    if exists('$PASTEFIRE_EMAIL') && len($PASTEFIRE_EMAIL) > 0
        let email = $PF_EMAIL
    elseif exists('g:pastefire_email') && len(g:pastefire_email) > 0
        let email = g:pastefire_email
    else
        echomsg 'please specify $PASTEFIRE_EMAIL or g:pastefire_email'
        return
    endif

    if exists('$PASTEFIRE_PASSWORD') && len($PASTEFIRE_PASSWORD) > 0
        let password = $PF_PASSWORD
    elseif exists('g:pastefire_password') && len(g:pastefire_password) > 0
        let password = g:pastefire_password
    else
        echomsg 'please specify $PASTEFIRE_PASSWORD or g:pastefire_password'
        return
    endif

    let ary = split(a:str)
    if get(ary, 0) ==# 'n'
        let lines = [get(ary, 1)]
    elseif get(ary, 0) ==# 'v'
        let save_cursor = getpos('.')
        let start_line = getpos("'<")
        let end_line = getpos("'>")
        call setpos('.', [0, end_line[1], 1, 0])
        if start_line[1] == end_line[1]
            let src = getline(start_line[1])
            let start = start_line[2] - 1
            let len = end_line[2] - start_line[2] + 1
            let lines = [strpart(src, start, len)]
        elseif end_line[2] > col('$')
            let lines = getline(getpos("'<")[1], getpos("'>")[1])
        else
            let lines = []
            for line in range(start_line[1], end_line[1])
                if line == start_line[1]
                    let lines += [strpart(getline(line), start_line[2] - 1)]
                elseif line == end_line[1]
                    let lines += [strpart(getline(line), 0, end_line[2])]
                else
                    let lines += [getline(line)]
                endif
            endfor
        endif
        call setpos('.', save_cursor)
    endif

    let lines[0] = 'clipboard=' . lines[0]
    let tmp = tempname()
    call writefile(lines, tmp, 'b')

    let fn = shellescape('@' . tmp)
    let email = shellescape('email=' . email)
    let password = shellescape('pwd=' . password)
    let url = 'https://pastefire.com/set.php'
    let com = printf('curl -k --data-binary %s -d %s -d %s %s',
                \ fn, email, password, url)
    echo 'sending...'
    let res = system(com)
    echo 'successful!'
    call delete(tmp)
endfunction

let &cpo = s:save_cpo
