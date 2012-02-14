**TrackPadConnector brings support for multi-touch Mac trackpads to the Adobe AIR platform.**

This fork is a major reworking of Matt LeGrand's [TrackPadConnector](https://github.com/mlegrand/TrackPadConnector), with the intention of simplify things a bit and adding support for selecting between multiple devices for input. (This allows use of the [Apple Magic Trackpad](http://www.apple.com/magictrackpad/) in combination with a laptop trackpad.)

Instead of collecting events through TUIO over the local network, this version runs tongseng (the trackpad middleware) in verbose mode and reads the event information directly through stdout.

Includes library and example projects intended for use in Flash Builder.