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

To create `term_start` wrappers at vim startup, call the following function:

### determined#command

This creates a command that wraps some command line tool in a call to `term_start`. Invoke as follows:

```vim
call determined#command(name, cmd, args)
```

#### Name

Type: string

The name of the vim command to create. This argument will be capitalized if it is not already because vim requires that custom commands be capitalized.

#### Cmd

Type: string

The static part of the command to run when the vim command is invoked. Usually this is the base binary name only, but it could be more if you run very specific things very often. For example:

```vim
call determined#command('TermGrep', 'grep -r')
```

#### Args

Type: dict

The following options are supported:

- `vertical`: Whether the terminal window should split vertically or not. Default `1` (because I use it this way far more often, even though the default for term_start is _not_ vertical). Regardless of the value passed here, you can invert this behavior by calling the created command with `!`. So in the `TermGrep` example above, by default, `:TermGrep foo` would open in a vertical split, but `:TermGrep! foo` would open in a horizontal one.
- `background`: Whether focus should be returned to your current window. Default `1`. The nice thing about `term_grep` is that it is async, so it doesn't interrupt what you're doing in vim. The not so nice thing is that it focuses you on the new terminal window instead of keeping you where you're already working. This flag just runs `wincmd p` at the end to return you to where you were previously working.
- `autoclose`: This param sets `'term_finish': 'close'` in the options passed to `term_start`. Default `0`. This is useful if you need to install something or run some other kind of build command of which you don't need to see the final output.
- `reuse`: If the same command has been run previously, reuse the existing window instead of creating a new one. Default `0`. Useful for running tests or other recurring commands.
- `singleton`: Like `reuse` but for the top level command. If you created `:TermGrep` with the `singleton` flag, all greps, regardless of other parameters, will happen in the same window. Default `0`.
- `expand`: Treat `%` (and `#`, `<cfile>`, etc.) specially and call `expand()` on it. Default `0`. `filename-modifiers` work here as well, so something like `:TermGrep foo %:h:h` would work as expected.
- `size`: The size of the terminal window. By default, `term_start` will use half the vertical or horizontal space, and `vim-determined` keeps this default. You can pass a number (or string number) to specify the number of rows or columns, depending on the vertical flag (i.e. this becomes `term_rows` or `term_cols`). But you can also pass a percentage as a string (e.g. '40%') and `vim-determined` will figure out the number of rows or columns to use. You can also pass the special flags `'small'` (or `'sm'` or `'quarter'`) to make it 25%, `'medium'` (or `'med'` or `'half'`) to make it 50% (but instead you should probably just let it use the default), or `'large'` (or `'lg'`) to make it 75%. Finally, there is a special value `auto` which will look at the window height and width ratios to determine _for you_ whether a vertical or horizontal split would be more efficient. Passing `auto` is incompatible with passing `rows` and `cols` (see below). It will also cause `!` to be ignored. The one exception to this parameter is that if `curwin` is set, this option is ignored, as it will use the space of the current window regardless.
- `rows`/`cols`: The `size` parameter is not very granular, since you might want different sizes based on the window orientation. In that case, you can pass the same kinds of identifiers for `rows` and/or `cols` as you can for `size` (except for `'auto'` which would not make sense).
- `complete`: Add custom completion. This maps basically one to one to the `-complete` option of commands, so pass it exactly as you would there.
- `tabnew`: Always run `cmd` in a new tab. Default `0`.
- `curwin`: Always run `cmd` in the current window. Default `0`.
- `term_args`: Finally, a catch all. This should be a dict, and anything you pass here will be added to the `term_start` options via `extend()`. Have a look at `:h term_start` for the various options supported.

### Commands

#### Commands created via determined#command
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

For completeness, `determined#command` also creates `E` and `T` versions for opening the command in a new tab or in the current window (even though you can configure this per command via [args](#args). So in the case above, the following commands are also created:

- `:ENpm` - Run the npm command in the current window.
- `:TNpm` - Run the npm command in a new tabpage.

#### Additional commands

`vim-determined` does include a few built in commands.

- `:TermClose[!]` - Close all open term windows (where the job is not currently running). When `<bang>` is included, stop running jobs and close those terms too.
- `:Term[!]` - A generic wrapper for call `term_start` with commands that you haven't created via `determined#command`. For instance, I don't use `find` very often, so I'm not creating a command for it with `determined#command`, but if I _need_ to use it in vim, I can run `:Term find . -name somefile.ext`. This uses the default arguments to `term_start`, which means it will open in a horizontal split. Use `<bang>` to open it in a vertical split.
- `:ETerm` - Like `:Term`, but in the current window.
- `:TTerm` - Like `:Term`, but in a new tabpage.
- `:VTerm` - Like `:Term`, but in a vertical split . . . so this is identical to `:Term!` but is included for completeness.
- `:STerm` - Synonymous with `:Term` but included for completeness.

### Mappings

Within a terminal window opened by `vim-determined`, `<C-r>` is mapped to rerun the original command. Hopefully, the symmetry is obvious. `<C-r>` is for "redo," but terminals are not modifiable, so I'm repurposing that keybinding to have specialized meaning.

## Contributing

I always try to be open to suggestions, but I do still have opinions about what this should and should not be so . . . it never hurts to ask before investing a lot of time on a patch.

## License

See [LICENSE](./LICENSE)
