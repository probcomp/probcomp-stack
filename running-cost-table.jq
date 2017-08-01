# Prices are from https://aws.amazon.com/ec2/pricing/on-demand/, in m$
"Hourly\tDaily\tMonthly\tID\t\t\tType\t\tName\t\t\tComment",
({ "c3.8xlarge": 1680,
   "t2.micro": 12,
   "m3.medium": 67,
   "m3.large": 133} as $costs |
 { "guest-1/instance": "Veronica, since Deloitte",
   "vsw-nelson/instance": "Veronica",
   "vsw-nelson-eeg/instance": "Veronica",
   "vsw-nelson-survey/instance": "Veronica",
   "mariehuber/instance": "Marie Huber",
   "school-39/instance": "Andrey Koval, Vancouver Island Health",
   "andrew/instance": "\tAndrew Bolton"
   } as $comment |
 [.Reservations[] .Instances[] |
 { name: (.Tags | map (select(.Key == "Name")) | .[0].Value),
   id: .InstanceId,
   type: .InstanceType,
   cost: $costs[.InstanceType],
   perday: ($costs[.InstanceType] * 24),
   thirtydays: ($costs[.InstanceType] * 24 * 30)}] |
 (sort_by(.name) |
  sort_by(- .cost) | .[] |
  (  (.cost / 1000 | tostring) + "\t"
   + (.perday / 1000 | tostring) + "\t"
   + (.thirtydays / 1000 | tostring) + "\t"
   + .id + "\t" + .type + " \t" + .name + "\t"
   + ($comment[.name]))),
 "$\(map(.cost) | add / 1000)\t$\(map(.perday) | add / 1000)\t" +
 "$\(map(.thirtydays / 1000) | add)\tTotal"
)
