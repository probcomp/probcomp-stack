#!/bin/sh

# Leave in the file url-cards.ps a printable document consisting of
# one url per page.  This is useful for printing out (single-sided!)
# and handing out at a workshop that involves giving the participants
# EC2 instances.  The pages can be folded over to write people's
# passwords inside.

set -eu

nup=3
pages=13
echo "" > url-cards.txt
(for page in `seq $pages`
do (for item in `seq $nup`
do
number=$(($page + $pages * ($item - 1)))
if [ "$item" -gt "1" ]; then
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
    echo "" >> url-cards.txt
fi
cat <<EOF >> url-cards.txt
MIT Probabilistic Computing Project
DARPA PPAML Summer School
Washington, DC, 2017

https://school-$number.stack.probcomp.net
Pass phrase: `cat jupyter-passwords/school-$number.passwd`
EOF
done)
echo "" >> url-cards.txt
done)

enscript -fCourier-Bold16 url-cards.txt -o url-cards.ps -b ''
