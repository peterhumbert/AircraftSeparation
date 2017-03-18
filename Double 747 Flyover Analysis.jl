using Gadfly
include("AircraftSeparation.jl")

interpolatedData = AircraftSeparation("Double 747 Flyover-KLM.csv",
  "Double 747 Flyover-BAW.csv",Date(2017,3,13))

println(test[5419,8]*1000*3.28/232) # output lateral spacing when photo was
                                    # taken (unit: plane lengths of 232 ft)

plotInLengths = plot(y=interpolatedData[4500:7000,end]*3.28*1000/232,
  yintercept=[0.5771305097],xintercept=[919],
  Geom.line,Geom.hline(color=colorant"yellow"),
  Geom.vline(color=colorant"yellow"))

draw(SVG("plotInLengths.svg",12inch,6inch), plotInLengths)
