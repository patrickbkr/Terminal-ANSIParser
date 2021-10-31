# ABSTRACT: Helper subs used to simplify parser tests

use v6.d;
use Test;

use Terminal::ANSIParser;


sub parse-all(@input) is export {
    my @parsed;
    my &parse-byte := make-ansi-parser(emit-item => { @parsed.push: $_ });
    parse-byte($_) for @input;

    @parsed
}

sub parses-as(@input, @expected, $desc) is export {
    my @parsed := parse-all(@input);
    is-deeply @parsed, @expected, $desc;
}

sub passthrough(@input, $desc) is export {
    parses-as @input, @input, $desc;
}

sub n-byte-simple-escape(@input, $n) is export {
    my @parsed = parse-all(@input);
    is @parsed.elems, @input / $n, "{$n}-byte escapes recognized";
    subtest "parsed results have correct type", {
        isa-ok $_, Terminal::ANSIParser::SimpleEscape for @parsed;
    }
    subtest "parsed results have correct length", {
        is .sequence.bytes, $n for @parsed;
    }
    subtest "first byte of parsed results is an escape", {
        is .sequence[0], 0x1B for @parsed;
    }

    @parsed
}

sub csi-test(@input, $desc) is export {
    my $expected = buf8.new(@input);
    my @parsed  := parse-all(@input);

    subtest $desc, {
        is     @parsed.elems, 1, "One sequence parsed for @input[]";
        isa-ok @parsed[0], Terminal::ANSIParser::CSI, "CSI detected";
        is     @parsed[0].sequence, $expected, "Sequence has expected bytes";
    }
}

sub csi-ignore(@input, $desc) is export {
    my $expected = buf8.new(@input);
    my @parsed  := parse-all(@input);

    subtest $desc, {
        is     @parsed.elems, 1, "One sequence parsed for @input[]";
        isa-ok @parsed[0], Terminal::ANSIParser::Ignored, "Sequence Ignored";
        is     @parsed[0].sequence, $expected, "Sequence has expected bytes";
    }
}
