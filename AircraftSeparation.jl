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
  importedData1 = readFile(csv1)
  importedData2 = readFile(csv2)

  n1 = size(importedData1)[1] # number of data samples for airplane 1
  n2 = size(importedData2)[1] # number of data samples for airplane 2

  print(typeof(importedData1[1,1]))
  print(typeof(importedData1[1,2]))
  typeof(importedData1[1,3])
  typeof(importedData1[1,4])
  # convert timestamp columns to type DateTime from string
  importedData1[:,1] = map(x->convertTimestamp(x,datDay),importedData1[:,1])
  importedData2[:,1] = map(x->convertTimestamp(x,datDay),importedData2[:,1])

  # convert altitude columns to type Int from string
  importedData1[:,end] = map(x->convertAlt(x),importedData1[:,end])
  importedData2[:,end] = map(x->convertAlt(x),importedData2[:,end])

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
  if length(comma) == 0
    return parst(Int,rawAlt)
  else
    return parse(Int, string(SubString(rawAlt,1,comma-1),
      SubString(rawAlt,comma+1,length(rawAlt))))
  end
end

function readFile(csv)
  # take filename string; determine which type of line return the file uses
  # then read the data appropriately
  # fs = open(csv) # doesn't work — TODO pass by ref issue?

  if search(readstring(open(csv)),'\r') != 0
    # file uses carriage return
    rawFileRead = readdlm(open("Double 747 Flyover-KLM.csv"),'\r')
    output = Array{Any}(length(rawFileRead),4)
    output[:,:] = map(x->parseRawLine(x),output[:,:])
    return readstring(open(csv))
  else
    # file uses line feed
    return readcsv(open(csv))
  end
end

function parseRawLine(str)
  # take a raw csv string; return array of string, Float64, Float64, string
  # example input: Mon 01:28:49 PM,46.2609,-92.5929,"36,000"
  output = Array{Any}(1,4)

  # get indicies of all commas and double quotation marks in inputted string
  commaIndices = findin(str,',') # expect 4
  quoteIndices = findin(str,'\"') # expect 2

  # expect last comma to be in the altitude column; remove it.
  # also remove double quotation marks
  for i in [quoteIndices[2]; commaIndices[end]; quoteIndices[1]]
    str = string(SubString(str,1,i-1),
      SubString(str,i+1,length(str)))
  end

  println(str)

  count = 1
  i = 5 # remove 3-letter day abbrev
  for j in commaIndices[1:end-1]
    output[count] = SubString(str,i,j-1)
    i = j+1
    count += 1
  end
  output[4] = SubString(str,i,length(str))


  output[2:3] = map(x->parse(Float64,x),output[2:3])

  println(output)
end

#=
datDay = Date(2017,3,13)

arrRaw = readcsv(open("test1.csv"))

strTimes = Array{String}(size(arrRaw)[1],1)
datTimes = Array{DateTime}(size(arrRaw)[1],1)
=#
