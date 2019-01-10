#!/bin/bash
set -e
if [[ $# -ne 1 ]]; then
  printf "\033[31merror expected 1 argument, got $#\033[0m\n"; 
  exit 1
elif [ ! -f $1 ]; then 
  printf "\033[31merror expected a file, $1 is not a file\033[0m\n"; 
  exit 1
fi
if ! [[ -x configure ]]; then 
  printf "\033[1m";
  printf "No configure file found, running ./autogen.sh . . .\n"; 
  printf "\033[0m"; 
  printf "\033[2m";
  ./autogen.sh;
  printf "\033[0m"; 
fi
if [[ ! -f config.log ]]; then 
  printf "\033[1m";
  printf "No config.log file found, running ./configure --enable-code-coverage . . .\n"; 
  printf "\033[0m"; 
  printf "\033[2m";
  ./configure --enable-code-coverage;
  ./autogen.sh;
  printf "\033[0m"; 
elif [[ ! -f Makefile ]]; then
  printf "\033[1m";
  printf "No Makefile found, running ./configure --enable-code-coverage . . .\n"; 
  printf "\033[0m"; 
  printf "\033[2m";
  ./configure --enable-code-coverage;
  printf "\033[0m"; 
elif ! grep -q "\.\/configure.*\-\-enable-code\-coverage" config.log; then 
  printf "\033[1m";
  printf "Didn't find --enable-code-coverage flag in config.log, running make clean && ./configure --enable-code-coverage . . .\n"; 
  printf "\033[0m"; 
  printf "\033[2m";
  make clean
  ./configure --enable-code-coverage;
  printf "\033[0m"; 
fi

printf "\033[1m";
printf "Running make -j8 . . .\n"; 
printf "\033[0m"; 
printf "\033[2m";
make -j8 | grep -v "Nothing to be done for"
printf "\033[0m"; 

printf "\033[1m";
printf "Deleting .gcda files . . .\n"; 
printf "\033[0m"; 
printf "\033[2m";
find . -name '*.gcda' -delete -print | sed -e 's:./::'
printf "\033[0m"; 

printf "\033[1m";
printf "Running Test(\"$1\"); in GAP . . .\n"; 
printf "\033[0m"; 
printf "\033[2m";
~/gap/bin/gap.sh -A -m 1g -T <<< "Test(\"$1\"); quit;";
printf "\033[0m"; 

printf "\033[1m";
printf "Running lcov and genhtml . . .\n"; 
printf "\033[0m"; 
printf "\033[2m";
lcov  --directory . --capture --output-file "coverage.info.tmp" --test-name "libsemigroups_1_0_0" --no-checksum --no-external --compat-libtool --gcov-tool "gcov" | grep -v "ignoring data for external file"
lcov  --directory . --remove "coverage.info.tmp" "/tmp/*" "/Applications/*" --output-file "coverage.info"
LANG=C genhtml  --prefix . --output-directory "coverage" --title "Digraphs kernel module code coverage" --legend --show-details "coverage.info"
printf "\033[0m"; 
rm -f coverage.info
rm -f coverage.info.tmp

printf "\033[1m";
printf "Deleting .gcda files . . .\n"; 
printf "\033[0m"; 
printf "\033[2m";
find . -name '*.gcda' -delete -print | sed -e 's:./::'
printf "\033[0m"; 

printf "\033[1m";
printf "See: coverage/index.html\n"
printf "\033[0m"; 

exit 0
