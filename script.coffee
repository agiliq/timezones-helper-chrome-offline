
origcities = "" 
tzdata=""
tzdatalower = ""
k=0
locations=""
utc = 0

$(document).ready ->
  #console.log "ready"
  
  updateUtc()
  d = new Date()
  #console.log d
  dstr=d.toLocaleString()
  datearr = dstr.split(" ")
  #console.log "time : "+datearr[4]+" off : "+datearr[5]+" stand : "+datearr[6]
  localtime = d.getTime()
  localoffset = d.getTimezoneOffset()*60000
  utc = localtime + localoffset
  #console.log "utc : "+utc
  
  bombayoff = 5.5
  bt = utc + (3600000*bombayoff)
  #console.log bt is localtime
  #console.log localtime
  nd = new Date(bt)
  ndstr = nd.toLocaleString()
  #ndarr = new Array()
  ndarr = ndstr.split(" ")
  #console.log ndarr[4].substr(0,5)
  
  $.ajax
      url : "tz/cities.csv"
      success : (cities) ->
        origcities = cities.toLowerCase()
        #console.log "cities loaded successfully"
      error : (e) ->
        console.log "Error loading cities"    
    
  $.ajax
    url : "tz/tz.csv"
    success : (tz) ->
      window.ttt = tz
      tzdata = tz
      tzdatalower = tz.toLowerCase()
      
      console.log "tzdata loaded successfully"
      renderRows()
    error : (e) ->
      console.log "Error loading tz data"   
  
  
  
    
$("#search_input").live
  keyup : (e) ->
    st = $(e.target).val().trim()
    st.toLowerCase()
    if st.length < 1
      $("#search_result").hide(200)
      return
    locations = "<br><ul class='searchresult_ul'>"
    k = 0  
    $("#search_result").html ""
    updateUtc()
    getLocations 0,st
    $("#search_result").show()
    $("#search_result").html locations
  focusout : ->
    $("#search_result").hide(1000)    
      
      
# add locations to the localStorage
$("ul.searchresult_ul").live
  click : (e) -> 
    console.log "-------li---------"
    sr_click(e)
 
    
    
    
$("#content .row .dates ul li").live
  mouseenter : (e) ->
    #console.log e
    $(".row .dates li").first().css "position","relative"
    #console.log $(e.target).attr("idx")    
    idx = $(e.target).attr("idx")
    $("#vband").css "height",parseInt($("#content .row").length)*72-41
    left = parseInt(idx)*28 
    $("#vband").css "left",left-2
    console.log left+" : "+idx
    #console.log $("#vband")

$("#content .row .dates").live  
  mouseleave : (e) ->
    left = parseInt($("#selectedband").css("left"))
    $("#vband").css "left",(left-2) 
    
    
    
$("#content .row .icons_homedelete .icon_delete").live
  click : (e) ->
    rowindex = parseInt($(e.target).parent().parent().attr("rowindex"))    
    oldobj = JSON.parse localStorage.addedLocations
    len = 0
    for key of oldobj
      len++
    i = rowindex+1
    while i<len
      oldobj[i-1] = oldobj[i] 
      i++
    delete oldobj[i-1]  
    localStorage.addedLocations = JSON.stringify oldobj  
    defaultind = parseInt localStorage.default
    if defaultind is (i-1)
      localStorage.default = (defaultind-1)
    renderRows()
    
$("#content .row .icons_homedelete .icon_home").live 
  click : (e) ->
    rowindex = parseInt($(e.target).parent().parent().attr("rowindex"))  
    ###  
    oldobj = JSON.parse localStorage.addedLocations
    tempobj = oldobj[rowindex]
    oldobj[rowindex] = oldobj[0]
    oldobj[0] = tempobj
    localStorage.addedLocations = JSON.stringify oldobj
    renderRows()
    ###
    console.log rowindex
    #ABOVE METHOD ALSO VERY NICE, BUT NOT ACCORDING TO THE SAMPLE SITE
    localStorage.default = rowindex
    renderRows()
    
    
    
    
$("lKNHi span").live
  click : (e) ->
    console.log "--------span------------------"
    #sr_click e
  mouseover : ->
    console.log "----------" 

$("ulsss").live
  click : (e) ->
    console.log "-------ul-------------"
    sr_click e
  mouseover : ->
    console.log "--"   

sr_click = (e) ->
  k = $(e.target).attr "k"
  offset = $("#lisr_"+k).attr "offset"
  timestr = $("#lisr_"+k).attr "timestr"
  both = $("#lisr_"+k+" span").text()
  botharr = both.split ","
  #botharr[0] country
  #botharr[1] city
  oldobj = JSON.parse localStorage.addedLocations
  len = 0
  for key of oldobj
    len++
  oldobj[len] = {}  
  oldobj[len].country = botharr[0]
  oldobj[len].city = botharr[1]
  oldobj[len].offset = offset
  localStorage.addedLocations = JSON.stringify oldobj
  renderRows()  
  
    
  
  
        
getLocations = (ind,st) =>
  if k>7
    locations+="</ul>"
    return
  k++   
  ind = parseInt ind
  if ind is 0
    ind = 0
  else
    ind++
  pi = parseInt(tzdatalower.indexOf(st,ind))
  if pi == -1
    locations+="</ul>"
    return
  subTillPi = tzdatalower.substr(0,pi)
  prevline = parseInt(subTillPi.lastIndexOf("\n"))

  if prevline is -1
    prevline = 0
  else if prevline is 0
    prevline = 0
  else
    prevline++  
      
  presline = parseInt(tzdatalower.indexOf("\n",pi))
  req = tzdata.substr prevline,presline-prevline
  reqArr = req.split(";")
  offset = reqArr[3]
  #console.log offset
  #console.log offset.length
  finaloff = ""
  if offset.length is 9
    offset = offset.substr(3,9)
    first = offset.substr(0,3)
    second = offset.substr(4,2)/60
    second = (second+"").substr(1)
    finaloff = parseFloat(first+second)
    
    #console.log "final : "+finaloff
  else
    finaloff = 0
  timestr = getNewTime(finaloff)
  #console.log timestr.toLocaleString()  
  timearr = timestr.split(" ")
  timearr[4] = (timearr[4]).substr(0,5)
    
  #console.log "---------------------"  
     
    
  
  locations+="<li class='searchresult_li' offset='"+finaloff+"' timestr='"+timestr+"' id='lisr_"+k+"' k='"+k+"'><span class='litz' k='"+k+"'>"+reqArr[1]+" , "+reqArr[0] + ",</span><span class='litime' k='"+k+"'>" + timearr[4]+ "</span></li>"
  getLocations presline,st       
  

renderRows = ->
  oldobj = {}
  if "addedLocations" of localStorage and "default" of localStorage
    
    oldobj = JSON.parse localStorage.addedLocations
  else
    #autodetect
    d = new Date()
    ad_utc = d.getTime() + (d.getTimezoneOffset()*60000)
    ad_offset = (d.getTime()-ad_utc)/3600000
    console.log "Detected offset  : "+ad_offset+"--"+(ad_offset+"").length
        
    formattedOffset = convertOffset ad_offset
    console.log formattedOffset
    pi = tzdata.indexOf formattedOffset
    #console.log window.ttt.indexOf("+05:30")
    console.log tzdata.indexOf("+05:30")
    console.log tzdata.length
    console.log pi
    if pi == -1
      #do something if offset not found in our tz data
      
      return
    subTillPi = tzdata.substr 0,pi
      
    prevline = subTillPi.lastIndexOf "\n"
    prevline = 0 if prevline is -1
    presline = tzdata.indexOf "\n",pi
    req = tzdata.substr prevline+1,presline-prevline-1
    console.log req
    reqArr = req.split ";"
    console.log reqArr
    newobj = {}
    
    newobj[0] = {}
    newobj[0].city = reqArr[0]
    newobj[0].country = reqArr[1]
    #newobj[0].standard = reqArr[2]
    floatOffset = convertOffsetToFloat reqArr[3].substr(3)
    
    if (floatOffset+"").indexOf "-" is -1
      if (floatOffset+"").indexOf "+" is -1
        floatOffset = "+"+floatOffset
    newobj[0].offset = floatOffset
    localStorage.addedLocations = JSON.stringify newobj
    localStorage.default = "0"
    oldobj = JSON.parse localStorage.addedLocations
    
    console.log "++++++++++"
  #now print old obj
  console.log "pp"
  
  updateUtc()
  
  ###
  floatOffset = oldobj[0].offset
  #floatOffset = convertOffsetToFloat offset
  timestr = getNewTime floatOffset
  timearr = timestr.split " "
  timearr[4] = timearr[4].substr(0,5)
  
  hourline = "<ul class='hourline_ul'>"
  i=0
  cl = ""
  while i<24
    if i<6
      cl="li_n"
    else if i>5 and i<8
      cl = "li_m"
    else if i>7 and i<19
      cl = "li_d"
    else if i>18 and i<22
      cl = "li_e"      
    else 
      cl = "li_n"
    i++
    hourline+="<span class='smallspace'></span> <li class='"+cl+"'>"+i+"</li>"  
  hourline+="</ul>"    
  
  
  row = "<div class='row'><div class='tzdetails'><div class='offset'><img class='homeicon' /> </div><div class='location'><span class='city'>"+oldobj[0].city+"</span><br><span class='country'>"+oldobj[0].country+"</span></div><div class='timedata'><span class='time'>"+timearr[4]+"</span><br><span class='timeextra'>"+timearr[0]+" , "+timearr[1]+" "+timearr[2]+" "+timearr[3]+"</span></div></div><div class='dates'>"+hourline+"</div></div>"     
  $("#content").html row
  ###
  
  defaultind = localStorage.default
 
  defaultobj = oldobj[defaultind]
  defaultoffset = parseFloat defaultobj.offset
  row = ""
  for ind of oldobj
    floatOffset = parseFloat oldobj[ind].offset
    console.log floatOffset+" : "+defaultoffset
    console.log floatOffset-defaultoffset
    #floatOffset = convertOffsetToFloat offset
    timestr = getNewTime floatOffset
    timearr = timestr.split " "
    timearr[4] = timearr[4].substr(0,5)
    console.log timearr
    diffoffset = floatOffset-defaultoffset    
    
    #now do hourline operation , and finally add it to "dates"
    diffoffsetstr = diffoffset+""
    hourstart = 1
    console.log "diffoffsetstr : "+diffoffsetstr
    if diffoffsetstr.indexOf("-") > -1
      diffoffsetstr = diffoffsetstr.substr(1)
      
      hourstart = 24+diffoffset 
      
      #hourstart = parseInt(diffoffsetstr)-1
      #if hourstart is -1
      #  hourstart = 23
      #  console.log "---------------------------------------------------" 
      console.log "houstart  : "+hourstart
    else
      #hourstart = parseInt diffoffsetstr
      hourstart = diffoffset
      console.log "hourstart +  : "+hourstart
    

      
    i=hourstart
    console.log "__-------------------------------___________________"
    console.log i


    tempstr = ""
    if (i+"").indexOf(".") > -1
        tempstr = (i+"").substr((i+"").indexOf(".")+1)
        tempstr = parseFloat tempstr
        if tempstr >= 0.5
          tempstr="30"
        else
          tempstr=""
    
    
    hourline = "<ul class='hourline_ul'>"
    idx = 0
    if i is 0
      i = 1
      
      cl = "li_24"
      hourline+=" <li class='"+cl+"' id='lihr_0' idx='"+idx+"' t='0' ><div class='span_hl' idx='"+idx+"'><span idx='"+idx+"' class='small' >"+timearr[1]+"</span><br><span idx='"+idx+"' class='small' >"+timearr[2]+"</span></div></li>"
      idx++
    #first loop, till 24-1
    
    while i<24
      if i<6
        cl="li_n"
      else if i>5 and i<8
        cl = "li_m"
      else if i>7 and i<19
        cl = "li_d"
      else if i>18 and i<22
        cl = "li_e"      
      else 
        cl = "li_n"
       
        
        
      hourline+=" <li class='"+cl+"' id='lihr_"+i+"' idx='"+idx+"' t='"+i+"' ><div class='span_hl' idx='"+idx+"'><span class='medium' idx='"+idx+"'>"+parseInt(i)+"</span><br><span class='small' idx='"+idx+"'>"+tempstr+"</span></div></li>"  
      
      if tempstr is ""
        hourline = hourline.replace "<span class='medium' idx='"+idx+"'>","<span idx='"+idx+"' >"
      idx++
      i++
    
      
    #second, directly put date
    unless hourstart is 0
      monInNum = getMonth timearr[1],{"type":"num"}
      d = new Date()
      d.setFullYear timearr[3],monInNum,timearr[2]
      d.setTime d.getTime()+86400000
      d = d.toLocaleString()
      nextdayarr = d.split " "
      
      
      cl = "li_24"
      hourline+=" <li class='"+cl+"' id='lihr_0' idx='"+idx+"' t='0'><div class='span_hl' idx='"+idx+"'><span idx='"+idx+"'  class='small'> "+nextdayarr[1]+"</span><br><span idx='"+idx+"' class='small' >"+nextdayarr[2]+"</span></div></li>"
      i=1
      idx++
    
    # third, loop upto hourstart-1
    
    
    while i<parseInt(hourstart)
      if i<6
        cl="li_n"
      else if i>5 and i<8
        cl = "li_m"
      else if i>7 and i<19
        cl = "li_d"
      else if i>18 and i<22
        cl = "li_e"      
      else 
        cl = "li_n"
      
      
      
      hourline+=" <li class='"+cl+"' id='lihr_"+i+"' idx='"+idx+"' t='"+i+"'><div class='span_hl' idx='"+idx+"'><span class='medium' idx='"+idx+"'>"+parseInt(i)+"</span><br><span class='small' idx='"+idx+"'>"+tempstr+"</span></div></li>"
      if tempstr is ""
        hourline = hourline.replace "<span class='medium' idx='"+idx+"'>","<span idx='"+idx+"' >"
      i++
      idx++
      
    hourline+="</ul>"
    row+= "<div class='row' id='row_"+ind+"' rowindex='"+ind+"' time='"+timearr[4]+"' ><div class='tzdetails'><div class='offset'>"+(floatOffset-defaultoffset)+"</div><div class='location'><span class='city'>"+oldobj[ind].city+"</span><br><span class='country'>"+oldobj[ind].country+"</span></div><div class='timedata'><span class='time'>"+timearr[4]+"</span><br><span class='timeextra'>"+timearr[0]+" , "+timearr[1]+" "+timearr[2]+" "+timearr[3]+"</span></div></div><div class='dates'>"+hourline+"</div></div> "
    
  $("#content").html row
  $("#content .row .dates li").first().append "<div id='vband'></div><div id='selectedband'></div>"
  #home, delete icons
  icons_homedelete = "<div class='icons_homedelete'><div class='icon_delete'>x</div><div class='icon_home'  ></div></div>"
  $("#content .row").append icons_homedelete
  
  #modifying style of default location row
  defaultind = parseInt localStorage.default
  
  $("#content #row_"+defaultind+" .icons_homedelete").html ""
  
  $("#content #row_"+defaultind+" .tzdetails .offset").html "<div class='homeicon'></div>"
  
  $(".row .dates li").first().css "position","relative"
  height = parseInt($("#content .row").length)*72-41
  left   = $("#content #row_"+defaultind).attr("time") 
  left = left.substr 0,left.indexOf(":")
  left = parseInt left
  console.log "left : "+left
  left = left*28
  console.log left+" : "+height
  $("#selectedband").css "height",height
  $("#selectedband").css "left",left
  left = parseInt($("#selectedband").css("left"))
  $("#vband").css "left",(left-2)
  $("#vband").css "height",$("#selectedband").css("height")
  
    
convertOffsetToFloat = (str) ->
  first = str.substr(0,str.indexOf(":"))  
  second = parseFloat(str.substr(str.indexOf(":")+1))/60
  second = (second+"").substr((second+"").indexOf(".")+1)
  return parseFloat(first+"."+second)
      

convertOffset = (ad_offset) ->
  sign = ""
  str = ""
  first = ""
  second = ""
  ad_offset = ad_offset+""
  if ad_offset.indexOf("-") > -1
    sign = "-"
    str = ad_offset.substr(1)
  else
    sign = "+"
    str = ad_offset
  if str.indexOf(".") > -1
    
    first = str.substr(0,str.indexOf("."))
    second = parseInt(str.substr(str.indexOf(".")+1))*6+""
    if first.length is 1
      first = "0"+first
    if second.length is 1
      second = "0"+second  
  else
    if str.length is 1
      first = "0"+str
    else
      first = str
    second = "00"
  return sign+first+":"+second      
      
convsdfsertOffset = (offset) ->
  newlocaloffset = offset
  offset = offset+""
  first = ""
  second = ""
  if offset.indexOf(".") > -1
    if offset.indexOf("-") > -1
      first = offset.substr(1,2)
      if first.length is 1
        first = "0"+first
      second = parseInt(offset.substr(4,5))*60
      if second.length is 1
        second = second+"0"
      sign = "-"  
    else
      first = offset.substr(0,1)
      if first.length is 1
        first = "0"+first
      second = parseInt(offset.substr(3,4))*60
      if second.length is 1
        second = second+"0"     
      sign = "+"  
  else
    if offset.indexOf("-") > -1
      sign = "-"
      if offset.length is 3
        first = offset.substr 1,2
      else  
        first = "0"+offset.substr(1,1)
      second = "00" 
    else
      sign = "+"
      if offset.length is 2
        first = offset.substr 0,2
      else
        first = offset.substr 0,1
      second = "00"      
          
  $("body").append "<h1>"+first+" : "+second+"</h1>"      

getMonth = (mon,options) -> 
  month = new Array()
  month[0]="January"
  month[1]="February"
  month[2]="March"
  month[3]="April"
  month[4]="May"
  month[5]="June"
  month[6]="July"
  month[7]="August"
  month[8]="September"
  month[9]="October"
  month[10]="November"
  month[11]="December"
  if options.type is "num"
    for m of month
      if month[m] is mon
        return m
  else if options.type is "str"
    return month[mon]
    
  
  
  
  
updateUtc = ->
  d = new Date()
  dstr=d.toLocaleString()
  datearr = dstr.split(" ")
  #console.log "time : "+datearr[4]+" off : "+datearr[5]+" stand : "+datearr[6]
  localtime = d.getTime()
  localoffset = d.getTimezoneOffset()*60000
  utc = localtime + localoffset
  
getNewTime = (offset) ->
  #console.log "utc ccc : "+utc
  newtime = utc + (3600000*offset)  
  #newtime = newtime.toLocaleString()
  #console.log newtime
  nd = new Date(newtime)
  #console.log nd
  ndstr = nd.toLocaleString()
  return ndstr
  #ndarr = ndstr.split(" ")
  #console.log ndarr[4].substr(0,5)
