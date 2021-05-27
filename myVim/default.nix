{ pkgs, lib ? pkgs.lib, ... }:

let cocNvim = import ./coc-nvim { inherit pkgs; };
in rec {
  inherit (cocNvim) cocSettingsFile;

  plugins = [
    pkgs.vimPlugins.airline
    pkgs.vimPlugins.gitgutter
    pkgs.vimPlugins.molokai
    pkgs.vimPlugins.nerdtree
    pkgs.vimPlugins.nord-vim
    pkgs.vimPlugins.typescript-vim
    pkgs.vimPlugins.vim-airline-themes
    pkgs.vimPlugins.vim-commentary
    pkgs.vimPlugins.vim-javascript
    pkgs.vimPlugins.vim-markdown
    pkgs.vimPlugins.vim-misc
    pkgs.vimPlugins.vim-nix
    pkgs.vimPlugins.vim-startify
    pkgs.vimPlugins.vim-toml
    pkgs.vimPlugins.vim-trailing-whitespace
    pkgs.vimPlugins.vim-wakatime
  ];

  # These are the Home-Manager settings and config
  settings = {
    hidden = true;
    mouse = "a";
    ignorecase = true;
    expandtab = true;
    number = true;
    relativenumber = true;
    shiftwidth = 2;
    tabstop = 4;
    smartcase = true;
  };

  extraConfig = builtins.concatStringsSep "\n\n" (lib.unique ([
    # Remap the leader key to single-quote instead of backslash
    ''let mapleader = "'"''

    # Use the basic shell for shell commands (even if using fish or whatever outside of vim)
    "set shell=/bin/sh"

    # Use the plugin indentation
    "filetype plugin indent on"

    # Use syntax highlighting
    "syntax enable"

    # Highlight all found matches 
    "set hlsearch"

    # Highlight matches while entering a new search
    "set incsearch"

    # Toggle highlighting all matches with <F3>
    ":noremap <F3> :set hlsearch! hlsearch?<CR>"

    # Turn off softtabstops and instead use smarttab (spaces instead of tabs)
    "set softtabstop=0 smarttab"

    # Let vim send colors to the terminal for some plugins
    "set termguicolors"

    # Use the Nord color scheme
    "colorscheme nord"

    # Try to force a terminal to match the colors that gVim would use
    "let g:rehash256 = 1"

    # New window from horizontal splits go below the current window
    "set splitbelow"

    # New window from vertical splits go to the right of the current window
    "set splitright"

    # Allow backspacing of indents, eols, and other characters in insert mode
    "set backspace=indent,eol,start"

    # Use 'jj' to exit Insert Mode
    ":imap jj <Esc>"

    # Turn off relative number in Insert Mode
    "autocmd InsertEnter * :set norelativenumber"

    # Turn on relative number when leaving Insert Mode
    "autocmd InsertLeave * :set relativenumber"

    # Don't create a swapfile: it almost always just makes problems
    "set noswapfile"

    # Save with Ctrl-S (instead of hanging silently)
    ":nmap <C-s> :w<CR>"
    ":imap <C-s> <Esc>:w<CR>a"

    # All folds are opened at start
    "set foldlevelstart=99"

    # syntax highlighting items specify folds
    "set foldmethod=syntax"

    # Don't fold markdown in the markdown plugin
    "let g:vim_markdown_folding_disabled = 1"
  ] ++

    # PHP.Vim
    [
      # Don't render PHP strings as HTML; too slow otherwise
      "let php_html_load = 0"

      # Force docblocks to have syntax highlighting
      ''
        function! PhpSyntaxOverride()
          " Put snippet overrides in this function.
          hi! link phpDocTags phpDefine
          hi! link phpDocParam phpType
        endfunction
      ''

      # Force docblocks to have syntax highlighting using PhpSyntaxOverride
      ''
        augroup phpSyntaxOverride
          autocmd!
          autocmd FileType php call PhpSyntaxOverride()
        augroup END
      ''

      # Generate CTags when saving PHP files
      ''
        au BufWritePost *.php silent! !eval '[ -f ".git/hooks/ctags" ] && .git/hooks/ctags' &
      ''
    ] ++

    # php-foldexpr.vim
    [
      # use COC for folding PHP
      "autocmd BufRead,BufNewFile *.php set foldmethod=manual"

      # Show fold info on right of close
      "let b:phpfold_text_right_lines=1"

      # Have `use` statements folded at start
      "let b:phpfold_use=1"

      # Fold docblocks separately
      "let b:phpfold_docblocks=1"
      "let b:phpfold_doc_with_funcs=0"
    ] ++

    # NERDTree
    [
      # Show tags on files and directories if changes
      ''
        let g:NERDTreeGitStatusIndicatorMapCustom = {
          \ "Modified"  : "✹",
          \ "Staged"    : "✚",
          \ "Untracked" : "✭",
          \ "Renamed"   : "➜",
          \ "Unmerged"  : "═",
          \ "Deleted"   : "✖",
          \ "Dirty"     : "✗",
          \ "Clean"     : "✔︎",
          \ 'Ignored'   : '☒',
          \ "Unknown"   : "?"
          \ }
      ''

      # NERDTrees File highlighting
      ''
        function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
          exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
          exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
        endfunction
      ''

      # Apply different colors to files depending on type
      "call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')"
      "call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')"
      "call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')"
      "call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')"
      "call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')"
      "call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')"
      "call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')"
      "call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')"
      "call NERDTreeHighlightFile('nix', 'brown', 'none', 'brown', '#151515')"
      "let g:NERDTreeGitStatusShowIgnored = 1"
      "nnoremap <F4> :NERDTreeToggle<CR>"
      ''
        autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif''
    ] ++

    # GitGutter
    [
      # always display the git gutter
      "set signcolumn=yes"
    ] ++

    # CtrlP-Z
    [
      # Enable Ctrlp-Z/Nerdtree integration
      "let g:ctrlp_z_nerdtree = 1"

      # Make the plugin available at startup
      "let g:ctrlp_extensions = ['Z', 'F']"
    ] ++

    cocNvim.extraConfig));
}
