#!/usr/bin/perl -w

use strict;
use Test;
BEGIN { plan tests => 8 }

BEGIN{ use Error 0.15; ok(1) };
require XML::Parser;
ok(1);
require XML::Writer;
ok(1);
require IO;
ok(1);
require Error;
ok(1);
require Carp;
ok(1);
require DBI;
ok(1);
require Authen::PAM;
ok(1);
