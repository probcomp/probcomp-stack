#!/bin/sh

# Leave in the file url-cards.ps a printable document consisting of
# one url per page.  This is useful for printing out (single-sided!)
# and handing out at a workshop that involves giving the participants
# EC2 instances.  The pages can be folded over to write people's
# passwords inside.

set -eu

echo "" > url-cards.txt
(for i in `seq 1 4 400`
do cat <<EOF >> url-cards.txt
MIT Probabilistic Computing Project
O'Reilly Artificial Intelligence Conference
New York, June 27, 2017

https://oreilly-$i.stack.probcomp.net
Password: `cat oreilly-passwords/$i.passwd`




MIT Probabilistic Computing Project
O'Reilly Artificial Intelligence Conference
New York, June 27, 2017

https://oreilly-$((i+1)).stack.probcomp.net
Password: `cat oreilly-passwords/$((i+1)).passwd`




MIT Probabilistic Computing Project
O'Reilly Artificial Intelligence Conference
New York, June 27, 2017

https://oreilly-$((i+2)).stack.probcomp.net
Password: `cat oreilly-passwords/$((i+2)).passwd`




MIT Probabilistic Computing Project
O'Reilly Artificial Intelligence Conference
New York, June 27, 2017

https://oreilly-$((i+3)).stack.probcomp.net
Password: `cat oreilly-passwords/$((i+3)).passwd`

EOF
done)

enscript -fCourier-Bold16 url-cards.txt -o url-cards.ps -b ''
