haversine(lat1,lon1,lat2,lon2) = 2 * 6372.8 *
  asin(sqrt(sind((lat2-lat1)/2)^2 +
  cosd(lat1) * cosd(lat2) * sind((lon2 - lon1)/2)^2))

#= NEEDED INPUT
  csv1:   a csv file of timestamps, lat, long, and altitude
  csv2:   a csv file of timestamps, lat, long, and altitude
  datDay: a Date object of the date on which the data was gathered
=#
function AircraftSeparation(csv1,csv2,datDay)
  # read raw data
  importedData1 = readcsv(open(csv1))
  importedData2 = readcsv(open(csv2))
  n1 = size(importedData1)[1] # number of data samples for airplane 1
  n2 = size(importedData2)[1] # number of data samples for airplane 2

  # prepare arrays to hold parsed timestamps

  importedData1[:,1] = map(x->convertTimestamp(x,datDay),importedData1[:,1])
  importedData2[:,1] = map(x->convertTimestamp(x,datDay),importedData2[:,1])

  importedData1[:,end] = map(x->convertAlt(x),importedData1[:,end])
  importedData2[:,end] = map(x->convertAlt(x),importedData2[:,end])

  TS1 = Array{DateTime}(n1)

  minimum(importedData1[:,1]) < minimum(importedData2[:,1]) ?
    minTS = minimum(importedData1[:,1]) : minTS = minimum(importedData2[:,1])

  #=
  min(importedData1[:,1]) < min(importedData2[:,1]) ?
    minTS = min(convert(Array{DateTime},importedData1[:,1])) :
    minTS = min(convert(Array{DateTime},importedData2[:,1]))
  =#

  maximum(importedData1[:,1]) > maximum(importedData2[:,1]) ?
    maxTS = maximum(importedData1[:,1]) : maxTS = maximum(importedData2[:,1])

  print(maxTS-minTS)
end

function convertTimestamp(rawTime, datDay)
  strTime = String(rawTime)

  if lowercase(SubString(strTime,14,15)) == "pm" &&
    SubString(strTime,5,6) != "12"
    hAdd = 12
  else
    hAdd = 0
  end

  return DateTime(Dates.year(datDay),Dates.month(datDay),
    Dates.day(datDay),parse(Int,SubString(strTime,5,6))+hAdd,
    parse(Int,SubString(strTime,8,9)),
    parse(Int,SubString(strTime,11,12)))
end

function convertAlt(rawAlt)
  comma = findin(rawAlt,",")[1]
  return parse(Int, string(SubString(rawAlt,1,comma-1),
    SubString(rawAlt,comma+1,length(rawAlt))))
end

datDay = Date(2017,3,13)

arrRaw = readcsv(open("test1.csv"))

strTimes = Array{String}(size(arrRaw)[1],1)
datTimes = Array{DateTime}(size(arrRaw)[1],1)
