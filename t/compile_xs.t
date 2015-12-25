use strict;
use warnings;
BEGIN {
  unless(eval qq{ use Test::Alien; 1 })
  {
    require Test::More;
    Test::More::plan(skip_all => 'test requires Test::Alien');
  }
}
use Test::Stream -V1;
use Alien::FFI;

plan 3;

alien_ok 'Alien::FFI';
my $xs = do { local $/; <DATA> };
xs_ok { xs => $xs, verbose => 1 }, with_subtest {
  my($module) = @_;
  plan 1;
  is $module->test, 0;
};

__DATA__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <ffi.h>

unsigned int foo(void)
{
  return 0xaa;
}

int
test(const char *class)
{
  ffi_cif   ffi_cif;
  ffi_type *args[1];
  void     *values[1];
  int       return_value;
  
  if(ffi_prep_cif(&ffi_cif, FFI_DEFAULT_ABI, 0, &ffi_type_uint32, args) == FFI_OK)
  {
    ffi_call(&ffi_cif, (void*) foo, &return_value, values);
  
    if(return_value == 0xaa)
      return 0;
    else
      return 2;
  }
  else
  {
    return 2;
  }
}

MODULE = TA_MODULE PACKAGE = TA_MODULE

int test(class);
    const char *class;
