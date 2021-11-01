NAME
====

Terminal::ANSIParser - ANSI/VT stream parser

SYNOPSIS
========

```raku
use Terminal::ANSIParser;

my @parsed;
my &parse-byte := make-ansi-parser(emit-item => { @parsed.push: $_ });
parse-byte($_) for $input-buffer.list;
```

DESCRIPTION
===========

`Terminal::ANSIParser` is a general parser for ANSI/VT escape codes, as defined by the related specs ANSI X3.64, ECMA-48, ISO/IEC 6429, and of course the actual physical DEC VT terminals generally considered the standard for escape code behavior.

The basic `make-ansi-parser()` routine builds and returns a byte-by-byte table-based binary parsing state machine, based on (and extended from) the error-recovering state machine built from observed DEC VT behavior described at [https://vt100.net/emu/dec_ansi_parser](https://vt100.net/emu/dec_ansi_parser).

Each time the parser determines that it has parsed enough bytes, it emits a token representing the parsed data, which can take one of the following forms:

  * A plain byte, for passed through data when no escape sequence is active

  * A `Terminal::ANSIParser::Sequence` object, if an escape sequence is parsed

  * A `Terminal::ANSIParser::String` object, if a control string is parsed

A few `Sequence` subclasses exist for separate cases:

  * `Ignored`: invalid sequences that the parser decides should be ignored

  * `Incomplete`: sequences that were cut off by the start of another sequence or the end of the input data (signaled by parsing an undefined "byte")

  * `SimpleEscape`: simple escape sequences such as function key codes

  * `CSI`: parameterized sequences beginning with `CSI` (`ESC [`)

Likewise, `String` has its own subclasses:

  * `DCS`: Device Control Strings

  * `OSC`: Operating System Commands

  * `SOS`: Strings beginning with a general Start Of String indicator

  * `PM`: Privacy Message (NOTE: NOT A SECURE FUNCTION)

  * `APC`: Application Program Command

AUTHOR
======

Geoffrey Broadwell <gjb@sonic.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Geoffrey Broadwell

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

