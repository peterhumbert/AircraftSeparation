using Gadfly

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

  # convert timestamp columns to type DateTime from string
  importedData1[:,1] = map(x->convertTimestamp(x,datDay),importedData1[:,1])
  importedData2[:,1] = map(x->convertTimestamp(x,datDay),importedData2[:,1])

  # convert altitude columns to type Int from string
  importedData1[:,end] = map(x->convertAlt(x),importedData1[:,end])
  importedData2[:,end] = map(x->convertAlt(x),importedData2[:,end])

  minimum(importedData1[:,1]) < minimum(importedData2[:,1]) ?
    minTS = minimum(importedData1[:,1]) : minTS = minimum(importedData2[:,1])

  maximum(importedData1[:,1]) > maximum(importedData2[:,1]) ?
    maxTS = maximum(importedData1[:,1]) : maxTS = maximum(importedData2[:,1])

  tdiff = Int((maxTS-minTS)/1000)
  lenInterp = tdiff+1

  # Assemble interpolation array
  # timestamps for interpolation, a/c #1 lat, a/c #1 long, a/c #1 alt,
  # a/c #2 lat, a/c #2 long, a/c #2 alt, separation
  interp = Array{Any}(lenInterp,8)

  # initialize interpolation array with time values
  for i=1:lenInterp
    interp[i,1] = minTS + Dates.Second(i-1)
  end

  # calculate and store a/c #1 interpolated lat, long, and alt
  for i=1:lenInterp
    
  end

end

function proto_plotAltitude(importedData1,importedData2)
  ticks = importedData1[end-180:60:end,1]
  plot(layer(x=importedData1[end-180:end,1],y=importedData1[end-180:end,4],
    Geom.line),
    layer(x=importedData2[end-180:end,1],y=importedData2[end-180:end,4],
    Geom.line), Guide.xticks(ticks=ticks))
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
  comma = findin(rawAlt,",")
  if length(comma) == 0
    return parse(Int,rawAlt)
  else
    return parse(Int, string(SubString(rawAlt,1,comma[1]-1),
      SubString(rawAlt,comma[1]+1,length(rawAlt))))
  end
end

function readFile(csv)
  # take filename string; determine which type of line return the file uses
  # then read the data appropriately
  # fs = open(csv) # doesn't work — TODO pass by ref issue?
  countCarriages = length(findin(readstring(open(csv)),'\r'))

  if countCarriages != 0
    output = Array{Any}(countCarriages,4) # assume last line has '\r'
    count = 1 # line number

    stream = open(csv)
    while (!eof(stream))
      str = readuntil(stream,'\r')
      str = SubString(str,1,length(str)-1) # remove carriage return

      parsed = parseRawLine(str)
      output[count,:] = parsed[:]

      count += 1
    end

    return output
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
  commaIndices = findin(str,',') # expect 3 or 4
  quoteIndices = findin(str,'\"') # expect 0 or 2

  if length(commaIndices) == 4 && length(quoteIndices) == 2
    # expect last comma to be in the altitude column; remove it.
    # also remove double quotation marks
    for i in reverse(quoteIndices)
      str = string(SubString(str,1,i-1),
        SubString(str,i+1,length(str)))
    end
    commaIndices = commaIndices[1:end-1]
  end

  # parse first 3 items
  count = 1
  i = 1
  for j in commaIndices
    output[count] = SubString(str,i,j-1)
    i = j+1
    count += 1
  end
  output[4] = SubString(str,i,length(str)) # parse altitude

  output[2:3] = map(x->parse(Float64,x),output[2:3]) # convert lat/long

  return output
end
