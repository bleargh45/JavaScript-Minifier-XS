# NAME

JavaScript::Minifier::XS - XS based JavaScript minifier

# SYNOPSIS

```perl
use JavaScript::Minifier::XS qw(minify);
$minified = minify($js);
```

# DESCRIPTION

`JavaScript::Minifier::XS` is a JavaScript "minifier"; its designed to remove
unnecessary whitespace and comments from JavaScript files, which also **not**
breaking the JavaScript.

`JavaScript::Minifier::XS` is similar in function to `JavaScript::Minifier`,
but is substantially faster as its written in XS and not just pure Perl.

# METHODS

- minify($js)

    Minifies the given `$js`, returning the minified JavaScript back to the
    caller.

# HOW IT WORKS

`JavaScript::Minifier::XS` minifies the JavaScript by removing unnecessary
whitespace from JavaScript documents.  Comments (both block and line) are also
removed, _except_ when (a) they contain the word "copyright" in them, or (b)
they're needed to implement "IE Conditional Compilation".

Internally, the minification process is done by taking multiple passes through
the JavaScript document:

## Pass 1: Tokenize

First, we go through and parse the JavaScript document into a series of tokens
internally.  The tokenizing process **does not** check to make sure you've got
syntactically valid JavaScript, it just breaks up the text into a stream of
tokens suitable for processing by the subsequent stages.

## Pass 2: Collapse

We then march through the token list and collapse certain tokens down to their
smallest possible representation.  _If_ they're still included in the final
results we only want to include them at their shortest.

- Whitespace

    Runs of multiple whitespace characters are reduced down to a single whitespace
    character.  If the whitespace contains any "end of line" (EOL) characters, then
    the end result is the _first_ EOL character encountered.  Otherwise, the
    result is the first whitespace character in the run.

## Pass 3: Pruning

We then go back through the token list and prune and remove unnecessary
tokens.

- Whitespace

    Wherever possible, whitespace is removed; before+after comment blocks, and
    before+after various symbols/sigils.

- Comments

    Comments that are either (a) IE conditional compilation comments, or that (b)
    contain the word "copyright" in them are preserved.  **All** other comments
    (line and block) are removed.

- Everything else

    We keep everything else; identifiers, quoted literal strings, symbols/sigils,
    etc.

## Pass 4: Re-assembly

Lastly, we go back through the token list and re-assemble it all back into a
single JavaScript string, which is then returned back to the caller.

# AUTHOR

Graham TerMarsch (cpan@howlingfrog.com)

# COPYRIGHT

Copyright (C) 2007-, Graham TerMarsch.  All Rights Reserved.

This is free software; you can redistribute it and/or modify it under the same
license as Perl itself.

# SEE ALSO

`JavaScript::Minifier`.
