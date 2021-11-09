# Tests

There should be no difference detected

cat accented.txt | ../../../utilities/bodge-eacute.pl 2> /dev/null | diff - accented.out


