# galvanize.vim

**This repository is deprecated in favor of [vim-buffest](https://github.com/rbong/vim-buffest)**.
Buffest is less buggy, supports vim better (versus neovim), and more.

This plugin creates buffers that represent registers. They update in real time
as the register is updated and can be edited to modify the register.

Registers a-z (which can also be represented as A-Z) and the unnamed register
can be used.

galvanize.vim requires neovim for its full range of features.

See the vim help documentation for more.

## Examples

Open register *b* in a horizontal split.
```
c@b
```

Open the unnamed register in the current window.
```
:GalvanizeEdit "
```

Open register *a* in a vertical split.
```
:GalvanizeVsplit a
```

Also open register *a*, but in a horizontal split.
```
:GalvanizeSplit A
```

Open register *z* in a new tab.
```
:GalvanizeTabe z
```

When editing any of the buffers opened by these commands, you can edit the
buffers and they will update the registers. Similarly, editing the registers
with vim actions will update the buffers.
