using Gadfly
include("AircraftSeparation.jl")

interpolatedData = AircraftSeparation("Double 747 Flyover-KLM.csv",
  "Double 747 Flyover-BAW.csv",Date(2017,3,13))

println(interpolatedData[5419,8]*1000*3.28/232) # output lateral spacing when
                                                # photo was taken
                                                # unit: plane lengths of 232 ft
    # the higher aircraft (KLM) is further south and further west
plotInLengths = plot(y=interpolatedData[4500:7000,end]*3.28*1000/232,
  Guide.xlabel("time (sec)"),
  Guide.ylabel("Difference in Position (Aircraft Lengths)"),
  yintercept=[0.5771305097],xintercept=[919],
  Geom.line,Geom.hline(color=colorant"yellow"),
  Geom.vline(color=colorant"yellow"))

draw(SVG("plotInLengths.svg",12inch,6inch), plotInLengths)

# UAL126 (B752) and THY36 (A333) analysis
interpolatedData = AircraftSeparation("UAL126-NA.csv","THY36-NA.csv",
  Date(2017,3,18))

# plot separation (in nm) vs time
plot(y=interpolatedData[5900:end,8]*1000*3.28/(1.15*5280),Geom.line)
