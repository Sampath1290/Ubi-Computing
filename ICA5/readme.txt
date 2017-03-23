1. Yes, we broke the Play-Doh in half and there were two circles marked.
This works because we iterate through all contours for each of the colors,
checking each area.

2. There are false positives occasionally. We could reduce the color range
and increase the area size needed to be marked. Increasing the area worked well
because the objects that we are sensing are close to the camera. Reducing the
color range did not work as well because of the way light shined off of the
Play-Doh. This created variation in the color that would not stay in a smaller
range as well.

3. We could have a painting application that draws the color that the user
is holding and traces that path and size of the Play-Doh for varied paint
strokes. Some problems with this include accuracy in starting and stopping
strokes as well as limited color detection or incorrect color detection.
