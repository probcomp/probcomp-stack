#!/bin/sh

# Leave in the file url-cards.ps a printable document consisting of
# one url per page.  This is useful for printing out (single-sided!)
# and handing out at a workshop that involves giving the participants
# EC2 instances.  The pages can be folded over to write people's
# passwords inside.

set -eu

echo "" > url-cards.txt
(for USER in $@
do cat <<EOF >> url-cards.txt



















https://$USER.stack.probcomp.net

EOF
done)

enscript -fCourier-Bold24 url-cards.txt -o url-cards.ps -b ''
