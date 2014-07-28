#!/usr/bin/env perl
# vim:ts=4:sw=4:expandtab
# © 2014 Michael Stapelberg, see LICENSE for licensing.

use strict;
use warnings;
use Encode qw(decode);
use utf8;
use v5.10;

my $pw = decode('utf-8', shift);
my @chars = split //, $pw;
my $output;

my %map = (
    '0' => 39,

    '-' => 45,
    '=' => 46,
    '[' => 47,
    ']' => 48,
    '\\' => 49,
    ';' => 51,
    '\'' => 52,
    '`' => 53,
    ',' => 54,
    '.' => 55,
    '/' => 56,

    '_' => 45+128,
    '+' => 46+128,
    '{' => 47+128,
    '}' => 48+128,
    '|' => 49+128,
    ':' => 51+128,
    '"' => 52+128,
    '~' => 53+128,
    '<' => 54+128,
    '>' => 55+128,
    '?' => 56+128,
);

$map{$_} = ord($_) - 97 + 4       for 'a' .. 'z';
$map{$_} = ord($_) - 65 + 128 + 4 for 'A' .. 'Z';
$map{$_} = ord($_) - 49 + 30      for '1' .. '9';

$output = join "", map {
    sprintf "%02x", $map{$_} // die "Unknown character: $_"
} split //, $pw;

if (length($output) > 76) {
    die "This password is too long, the YubiKey only stores up to 76 bytes.";
}

$output .= '0' x (76 - length($output));

my $first = substr($output, 0, 32);
my $second = substr($output, 32, 12);
my $third = substr($output, 44, 32);

printf "ykpersonalize -1 -o-append-cr -o-static-ticket -oshort-ticket -o-strong-pw1 -o-strong-pw2 -oman-update -ofixed=h:%s -ouid=%s -a%s\n", $first, $second, $third;
