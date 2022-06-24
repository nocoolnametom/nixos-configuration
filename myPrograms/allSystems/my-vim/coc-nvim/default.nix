{ pkgs, ... }:

# In vim, check the health of the COC server by entering, the command:
#
# ```
# :CocInfo
# ```
#
# Also, check all of the known extensions for CoC:
#
# ```
# :CocList extensions
# ```

{
  plugins = with pkgs.vimPlugins;
    with (import ../plugins/cocPlugins { inherit pkgs; }); [

      # PHP Intelephense plugin - This is a custom plugin; remember to put the license code in ~/intelephense/licence.txt
      # coc-intelephense

      # Syntax, linting, and autosuggest
      coc-css

      # Show suggestions for Emmet HTML expansions
      coc-emmet

      # Show eslinting warnings and errors
      coc-eslint

      # Golang plugin
      coc-go

      # Show color hexes with matching color highlighting
      coc-highlight

      # HTML syntax, linting, and autosuggest
      coc-html

      # JSON syntax, linting, and autosuggest
      coc-json

      # Additional lists like recently used files
      coc-lists

      # Communication server between VSCode-style code engine and vim
      coc-nvim

      # Hightlight matching bracket pairs
      coc-pairs

      # Autoformat on save
      coc-prettier

      # Python plugin (kinda buggy)
      coc-python

      # Rust plugin
      coc-rls

      # Snippets expansion
      coc-snippets

      # TSLint syntax and linting on TS/TSX files
      coc-tslint-plugin

      # TypeScript server
      coc-tsserver

      # TeX syntax, linting, and autosuggest
      coc-vimtex

      # Yaml syntax, linting, and autosuggest
      coc-yaml
    ];
  extraConfig = [
    # if hidden is not set, TextEdit might fail.
    "set hidden"

    # Some servers have issues with backup files, see #649
    "set nobackup"
    "set nowritebackup"

    # Better display for messages
    "set cmdheight=2"

    # You will have bad experience for diagnostic messages when it's default 4000.
    "set updatetime=300"

    # don't give |ins-completion-menu| messages.
    "set shortmess+=c"

    # always show signcolumns
    "set signcolumn=yes"

    # Use tab and "return/enter" for trigger completion with characters ahead and navigate
    # Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
    ''
      inoremap <silent><expr> <TAB>
       \ pumvisible() ? "\<C-n>" :
       \ <SID>check_back_space() ? "\<TAB>" :
       \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
    ''

    # Don't check on back space
    ''
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction
    ''

    # Use <c-space> for trigger completion.
    "inoremap <silent><expr> <c-space> coc#refresh()"

    # Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
    # Coc only does snippet and additional edit on confirm.
    ''inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"''

    # Use `[c` and `]c` for navigate diagnostics
    "nmap <silent> [c <Plug>(coc-diagnostic-prev)"
    "nmap <silent> ]c <Plug>(coc-diagnostic-next)"

    # Remap keys for gotos
    "nmap <C-LeftMouse> :call CocAction('jumpDefinition', 'tab drop')<CR>"
    "nmap <silent> gb :call CocAction('jumpDefinition', 'tab drop')<CR>"
    "nmap <silent> gd <Plug>(coc-definition)"
    "nmap <silent> gq <Plug>(coc-declaration)"
    "nmap <silent> gy <Plug>(coc-type-definition)"
    "nmap <silent> gi <Plug>(coc-implementation)"
    "nmap <silent> gr <Plug>(coc-references)"

    # Prevent "$" from being part of autocompletes on PHP files
    # "autocmd FileType php set iskeyword+=$zzs"

    # Use K for show documentation in preview window
    "nnoremap <silent> K :call <SID>show_documentation()<CR>"

    # Show documenation from docblocks,etc, when selecting suggestions
    ''
      function! s:show_documentation()
        if &filetype == 'vim'
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction
    ''

    # Highlight symbol under cursor on CursorHold
    "autocmd CursorHold * silent call CocActionAsync('highlight')"

    # Remap for rename current word
    "nmap <leader>rn <Plug>(coc-rename)"

    # Remap for format selected region
    "xmap <leader>f  <Plug>(coc-format-selected)"
    "nmap <leader>f  <Plug>(coc-format-selected)"

    # Fold/Open
    "nmap <leader>F  :call CocAction('fold', 'region')<CR>"
    "nmap <leader>I  :call CocAction('fold', 'imports')<CR>"

    ''
      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end
    ''

    # Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
    "xmap <leader>a  <Plug>(coc-codeaction-selected)"
    "nmap <leader>a  <Plug>(coc-codeaction-selected)"

    # Remap for do codeAction of current line
    "nmap <leader>ac  <Plug>(coc-codeaction)"
    # Fix autofix problem of current line
    "nmap <leader>qf  <Plug>(coc-fix-current)"

    # Create mappings for function text object, requires document symbols feature of languageserver.
    "xmap if <Plug>(coc-funcobj-i)"
    "xmap af <Plug>(coc-funcobj-a)"
    "omap if <Plug>(coc-funcobj-i)"
    "omap af <Plug>(coc-funcobj-a)"

    # Use `:Format` to format current buffer
    "command! -nargs=0 Format :call CocAction('format')"

    # Use `:Fold` to fold current buffer
    "command! -nargs=? Fold :call     CocAction('fold', <f-args>)"

    # use `:OR` for organize import of current buffer
    "command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')"

    # Add status line support, for integration with other plugin, checkout `:h coc-status`
    "set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}"

    # Using CocList
    # Show all diagnostics
    "nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>"
    # Manage extensions
    "nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>"
    # Show commands
    "nnoremap <silent> <space>c  :<C-u>CocList commands<cr>"
    # Find symbol of current document
    "nnoremap <silent> <space>o  :<C-u>CocList outline<cr>"
    # Search workspace symbols
    "nnoremap <silent> <space>s  :<C-u>CocList -I -A symbols<cr>"
    # Do default action for next item.
    "nnoremap <silent> <space>j  :<C-u>CocNext<CR>"
    # Do default action for previous item.
    "nnoremap <silent> <space>k  :<C-u>CocPrev<CR>"
    # Resume latest coc list
    "nnoremap <silent> <space>p  :<C-u>CocListResume<CR>"

    # Coc-Prettier
    "command! -nargs=0 Prettier :CocCommand prettier.formatFile"
    "vmap <leader>f  <Plug>(coc-format-selected)"
    "nmap <leader>f  <Plug>(coc-format-selected)"
  ];

  cocSettingsFile = builtins.toJSON {
    "coc.preferences.extensionUpdateCheck" = true;
    "coc.preferences.formatOnSaveFiletypes" = [
      "css"
      "go"
      "json"
      "javascript"
      "javascriptreact"
      "Markdown"
      "typescript"
      "typescriptreact"
      "typescript.tsx"
    ];
    "coc.preferences.hoverTarget" = "float";
    "diagnostic.enable" = true;
    "diagnostic.errorSign" = "•";
    "diagnostic.infoSign" = "•";
    "diagnostic.warningSign" = "•";
    "emmet.excludeLanguages" =
      [ "go" "javascript" "json" "markdown" "nix" "php" "python" "typescript" ];
    "eslint.autoFixOnSave" = false;
    "eslint.filetypes" = [
      "javascript"
      "javascriptreact"
      "typescript"
      "typescriptreact"
      "typescript.tsx"
    ];
    "html.format.enable" = true;
    "json.format.enable" = false;
    "languageserver" = {
      # Bash language server is broken so it's not installed
      #"bash" = {
      #  "command" = "bash-language-server";
      #  "args" = [ "start" ];
      #  "filetypes" = [ "sh" ];
      #  "ignoredRootPaths" = [ "~" ];
      #};
    };
    "suggest.echodocSupport" = true;
    "suggest.maxCompleteItemCount" = 20;
    "suggest.snippetIndicator" = " ►";
    "yaml.format.bracketSpacing" = true;
  };
}
