# Vim-Determined

A wrapper around vim 8's new term_start to make it friendlier and easier to use.

## Overview

Vim 8 added asynchronous terminal support via `term_start`, and it's _really neat_. Except it's a _pain_ to use. I basically have to do `:h term_start` every time I think I might want to use it. But it seems like it wasn't really intended to be used directly, since there's no command for it. You have to invoke it with `:call term_start`. I could've made a simple command like `:Term cmd { args }` but that's annoying to type every time, so instead, this plugin exposes the `determined#command` function, which you should call in your vim config setup (e.g. in vimrc). This function will create commands for you that wrap specific invocations of `:call term_start` to make it easy to use. For example, here are the current commands I'm creating in my setup via `determined#command`:

```vim
" Example:
" :Npm install some-module
call determined#command('Npm', 'npm', { 'vertical': 0, 'rows': '5', 'cols': '40%' })

" Example:
" :Repl
" start an interactive node repl
call determined#command('Repl', 'node', { 'autoclose': 0, 'background': 0 })

" Example:
" :Node -e "[1, 2, 3].map((i) => i * i)"
call determined#command('Node', 'node', { 'vertical': 0, 'rows': '10', 'cols': '40%' })

" Example:
" :Rg blah ./test
call determined#command('Rg', 'rg', { 'background': 0, 'autoclose': 0 })

" Example:
" :Grunt spec:unit
call determined#command('Grunt', 'grunt', { 'autoclose': 0, 'reuse': 1 })
```

`vim-determined` makes it easy to interact with any command line tool directly from node. I'd suggest `git` as an obvious candidate except it _still_ wouldn't be as good as [vim-fugitive](https://github.com/tpope/vim-fugitive).

## Requirements

This plugin requires vim at or above version 8 compiled with `+terminal` (check `:echo has('terminal')`).

## Installation

If you don't have a preferred installation method, I really like vim-plug and recommend it.

#### Manual

Clone this repository and copy the files in plugin/, autoload/, and doc/ to their respective directories in your vimfiles, or copy the text from the github repository into new files in those directories. Make sure to run `:helptags`.

#### Plug (https://github.com/junegunn/vim-plug)

Add the following to your vimrc, or something sourced therein:

```vim
Plug 'tandrewnichols/vim-determined'
```

Then install via `:PlugInstall`

#### Vundle (https://github.com/gmarik/Vundle.vim)

Add the following to your vimrc, or something sourced therein:

```vim
Plugin 'tandrewnichols/vim-determined'
```

Then install via `:BundleInstall`

#### NeoBundle (https://github.com/Shougo/neobundle.vim)

Add the following to your vimrc, or something sourced therein:

```vim
NeoBundle 'tandrewnichols/vim-determined'
```

Then install via `:BundleInstall`

#### Pathogen (https://github.com/tpope/vim-pathogen)

```sh
git clone https://github.com/tandrewnichols/vim-determined.git ~/.vim/bundle/vim-determined
```

## Usage

At the moment, vim-determined has only one function that you need to care about:

### determined#command

Creates a command that wraps some command line tool in a call to `term_start`. Invoke as follows:

```vim
call determined#command(name, cmd, args)
```

#### Name

Type: string

The name of the vim command to create. This argument will be capitalized if it is not already because vim requires that custom commands be capitalized.

#### Cmd

Type: string

The static part of the command to run when the vim command is invoked. Usually this is the base binary name only, but it could be more if you run very specific things very often. For example,

```vim
call determined#command('TermGrep', 'grep -r')
```

doesn't seem unreasonable.

#### Args

Type: dict

The following options are supported:

- `vertical`: Whether the terminal window should split vertically or not. Default `1`. Regardless of the value passed here, you can invert this behavior by calling the created command with `!`. So in the `TermGrep` example above, by default, `:TermGrep foo` would open in a vertical split, but `:TermGrep! foo` would open in a horizontal one.
- `background`: Whether focus should be returned to your current window. Default `1`. The nice thing about `term_grep` is that it is async, so it doesn't interrupt what you're doing in vim. The not so nice thing is that it focuses you on the new terminal window instead of keeping you where you're already working. This flag just runs `wincmd p` at the end to return you to where you were previously working.
- `autoclose`: This param sets `'term_finish': 'close'` in the options passed to `term_start`. Default `0`. This is useful if you need to install something or run some other kind of build command of which you don't need to see the final output.
- `reuse`: If the same command has been run previously, reuse the existing window instead of creating a new one. Default `0`. Useful for running tests or other recurring commands.
- `expand`: Treat `%` specially and replace it with the current file name. Default `0`. Eventually, this will hopefully do _more_ expansion. For instance `grep -r foo %:h` to grep in the file's directory would be nice.
- `size`: The size of the terminal window. By default, `term_start` will use half the vertical or horizontal space, and `vim-determined` keeps this default. You can pass a number (or string number) to specify the number of rows or columns, depending on the vertical flag (i.e. this becomes `term_rows` or `term_cols`). But you can also pass a percentage as a string (e.g. '40%') and `vim-determined` will figure out the number of rows or columns to use. You can also pass the special flags `small` (or `sm` or `quarter`) to make it 25%, `medium` (or `med` or `half`) to make it 50% (but instead you should probably just let it use the default), or `large` (or `lg`) to make it 75%.
- `rows`/`cols`: The `size` parameter is not very granular, since you might want different sizes based on the window orientation. In that case, you can pass the same kinds of identifiers for `rows` and/or `cols` as you can for `size`.
- `complete`: Add custom completion. This maps basically one to one to the `-complete` option of commands, so pass it exactly as you would there.
- `term_args`: Finally, a catch all. This should be a dict, and anything you pass here will be added to the `term_start` options via `extend()`. Have a look at `:h term_start` for the various options supported.

### Commands

Once the command is created, you can call it with additional string parameters to pass to `term_start`. For example, if you created a command like this:

```vim
call determined#command('Npm', 'npm')
```

You can invoke it in any of the following ways:

- `:Npm install foo`
- `:Npm uninstall foo`
- `:Npm test`
- `:Npm run custom-script`
- `:Npm ls`
- `:Npm install -D grunt grunt-contrib-copy grunt-contrib-uglify grunt-contrib-concat`
- etc. etc.

## Contributing

I always try to be open to suggestions, but I do still have opinions about what this should and should not be so . . . it never hurts to ask before investing a lot of time on a patch.

## License

See [LICENSE](./LICENSE)
