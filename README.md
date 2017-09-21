# AircraftSeparation
This repo contains a collection of [Julia](https://julialang.org/) functions for analyzing the [FlightAware](http://flightaware.com/) track log data of two aircraft flying in tandem.

While home during spring break, I noticed a pair of Boeing 747s flying in northern Minnesota airspace -- British Airways (BAW) 195 from London Heathrow to Houston and KLM 25 from Amsterdam to Houston.

This by itself is no particularly interesting observation. 

What made the circumstance unique was that one aircraft was gradually overtaking the other at a rate that would place them in extremely close proximity by the time they reached my location. This is shown in the photo below. KLM 25 is leading at 36000 feet, and BAW 195 is following at 34000 feet.

<img src="https://github.com/peterhumbert/AircraftSeparation/blob/master/IMAG1595.jpg" height="300px" />

The code in this repo was used to generate the following plot, which shows that the two aircraft were within approximately 40 lengths of each other for 40 minutes and were near their closest when they passed overhead (marked by the yellow lines).

<img src="https://github.com/peterhumbert/AircraftSeparation/blob/master/plotInLengths.svg" width="100%">
