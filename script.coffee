
origcities = ""
tzdata=""
tzdatalower = ""
k=0
locations=""
utc = 0
selecteddate = {}
rowsortstart = ""
rowsortstop = ""
#domain_name = "http://localhost/timezoneconvertor"
domain_name = "http://533f.localtunnel.com/timezoneconvertor"
#added_locations_status = ""
#first set selecteddate to current date, later user can change

$(document).ready ->
  updateUtc()
  d = new Date()
  dstr=d.toLocaleString()
  datearr = dstr.split(" ")
  localtime = d.getTime()
  localoffset = d.getTimezoneOffset()*60000
  utc = localtime + localoffset

  bombayoff = 5.5
  bt = utc + (3600000*bombayoff)
  nd = new Date(bt)
  ndstr = nd.toLocaleString()
  ndarr = ndstr.split(" ")
  setSelectedDate()

  $.ajax
    url : "tz/tz.csv"
    success : (tz) ->
      window.ttt = tz
      tzdata = tz
      tzdatalower = tz.toLowerCase()

      #console.log "tzdata loaded successfully"
      renderRows()
      if window.location.search != ""
        #if typeof(localStorage.addedLocations) == "undefined"
        renderRows(generate_meeting_link)
        #generate_meeting_link()
      #  #renderRows(generate_meeting_link)
      #  console.log "renderRows(a)"
      #  renderRows()
      #  renderRows(generate_meeting_link)
    error : (e) ->
      #console.log "Error loading tz data"

  #Meeting Link
  #if window.location.search != "" and typeof(localStorage.addedLocations) != "undefined"

      
    #setTimeout (->
    #  generate_meeting_link()
    #), 3000

generate_meeting_link = ->
    console.log "Genrat meeting lik starte"
    search = decodeURI window.location.search
    search = search.substr 1, search.length
    params_arr = search.split("&")
    time_arr = params_arr.pop()
    param_obj = {}
    for key in params_arr
      temp = key.split("=")
      param_obj[temp[0]] = temp[1]
    oldobj = JSON.parse localStorage.addedLocations
    console.log JSON.stringify oldobj
    keys = Object.keys
    old_keys = keys(oldobj)
    param_keys = keys(param_obj)
    duplicate_keys = []
    i = 0

    original_param_obj = {}
    while i<param_keys.length
      temp_arr = param_obj[i].split(";")
      temp_obj = 
        'city': temp_arr[0]
        'country': temp_arr[1]
        'offset': temp_arr[2]
        'time': temp_arr[3]
      param_obj[i] = temp_obj
      original_param_obj[i] = temp_obj
      j = 0
      while j<old_keys.length
        if param_obj[i].city.trim() == oldobj[j].city.trim() and param_obj[i].country.trim() == oldobj[j].country.trim()
          duplicate_keys += [i]
          break
        j++
      i++

    
    for key in duplicate_keys
      delete param_obj[key]

    temp_param_obj = {}
    i = 0
    for key, val of param_obj
      temp_param_obj[i] = val
      i++
    
    param_obj = temp_param_obj
    param_keys = keys(param_obj)
    i = old_keys.length
    j = 0
    while j<param_keys.length
      oldobj[i] = param_obj[j]
      i++
      j++

    localStorage.addedLocations = JSON.stringify oldobj
    renderRows()

    #Show on Modal
    html = "<table class='table table-striped'>"
    for key, val of original_param_obj
      html += "<tr><td>"+val.city+"</td><td>"+val.country+"</td><td>"+val.time+"</td></tr>"
    $("#meeting_details .modal-body").html(html).parent().show()
    $("#meeting_details").draggable 
      handle: '.meeting_details_move'



remove_key = (obj, pos) ->
  i = pos
  len = Object.keys(obj).length
  while i<len-1
    obj[i] = obj[i+1]
    i++
  delete obj[len-1]
  return obj



$("#search_input").live
  keyup : (e) ->
    $(".searchresult_li").removeClass("temp_active")
    if e.keyCode == 13
      k = $(".searchresult_li.active_search").attr "k"
      sr_click(e, k)
      $("#search_result").hide()
      return
    if e.keyCode == 40
      if $(".searchresult_li").length == 0
        return
      if $(".searchresult_li.active_search").length > 0
        if $(".searchresult_li.active_search").next().length > 0
          $(".searchresult_li.active_search").addClass("temp_active")
          $(".searchresult_li").removeClass("active_search")
          $(".searchresult_li.temp_active").next().addClass("active_search")
        else
          $(".searchresult_li").removeClass("active_search").first().addClass("active_search")
      else
        $(".searchresult_li").first().addClass("active_search")
      return
    if e.keyCode == 38
      if $(".searchresult_li").length == 0
        return
      if $(".searchresult_li.active_search").length > 0
        if $(".searchresult_li.active_search").prev().length > 0
          $(".searchresult_li.active_search").addClass("temp_active")
          $(".searchresult_li").removeClass("active_search")
          $(".searchresult_li.temp_active").prev().addClass("active_search")
        else
          $(".searchresult_li").removeClass("active_search").last().addClass("active_search")
      else
        $(".searchresult_li").first().addClass("active_search")
      return
    st = $(e.target).val().trim().toLowerCase()
    st.toLowerCase()
    if st.length < 1
      #$("#search_result").hide(200)
      $("#search_result").slideUp()
      return
    locations = "<br><ul class='searchresult_ul'>"
    k = 0
    $("#search_result").html ""
    updateUtc()
    getLocations 0,st
    $("#search_result").html locations
    if $("#search_result").css("display") == "none"
      $("#search_result").slideDown()

  focusout : ->
    #$("#search_result").hide(1000)
    setTimeout (->
      $("#search_result").slideUp()
    ), 300


# add locations to the localStorage
#$("#search_result").on "click", {}, (e) ->
#   console.log "------clicked-----"
#   sr_click(e)
$("li.searchresult_li").live
  click : (e) ->
    sr_click(e)

$(".searchresult_ul").live
  mouseenter: () ->
    $(".searchresult_li").removeClass("active_search")




$("#content .row .dates ul li").live
  mouseenter : (e) ->
    $(".row .dates li").first().css "position","relative"
    idx = $(e.target).attr("idx")
    if typeof(idx) != "undefined"
      $("#vband").attr "idx",idx
      $("#vband").css "height",parseInt($("#content .row").length)*72-41
      left = parseInt(idx)*28 + 320
      $("#vband").css "left",left

#$("#content .row .dates").live
$("#content").live
  mouseleave : (e) ->
    left = parseInt($("#selectedband").css("left"))
    $("#vband").css "left",(left-2)


$("#selectedband").live
  mouseenter: (e) ->
    $("#content").sortable('disable')
  mouseout: (e) ->
    $("#content").sortable('enable')


$("#vband").live
  mouseenter: (e) ->
    $("#content").sortable('disable')
  mouseout: (e) ->
    $("#content").sortable('enable')

  click : (e) ->
    #console.log e

    $(".canhide").css "opacity","0.1"

    idx = $(e.target).attr "idx"
    if idx is undefined
      return
    t = new Array()
    city = new Array()
    country = new Array()
    yeardetails = new Array()
    #console.log "printing row"
    param_string = "?"
    i = 0
    for ele in $(".row")
      #console.log ele.id
      #tinFloat = $("#"+ele.id+" #lihr_"+idx).attr("t")
      tText = convertOffset $("#"+ele.id+" #lihr_"+idx).attr("t")
      #console.log tText
      t.push tText.substr(1)
      city.push $("#"+ele.id+" .city").text()
      country.push $("#"+ele.id+" .country").text()
      yeardetails.push $("#"+ele.id+" #lihr_"+idx).attr("details")
      param_string += i+"="+city[i]+";"+country[i]+";"+$("#"+ele.id).attr('original_offset')+";"+yeardetails[i]+", "+t[i]+"&"
      #param_string += i+"="+city[i]+";"+country[i]+";"+t[i]+"&"
      i++

    param_string += "time="+$($('.row')[0]).attr('original_offset')+";"+t[0]
    #param_string = param_string.substr 0, param_string.length-1
    param_string = encodeURI param_string
    #console.log "prointed"
    #console.log t+" : "+city+" : "+country
    $("#newevent").show()
    $(".meeting_link").html "<a href='"+domain_name+param_string+"'><strong>Link</strong></a>"
    $("#newevent_time").text ""
    $("#newevent_msg").text ""
    $("#event_name").text ""
    tabl = "<table id='newevent_table' class='table table-striped' ><thead><th>City</th><th>Country</th><th>Time</th></thead>"

    for ind of t

      #$("#newevent_time").append "\n"+city[ind]+" : "+country[ind]+" : "+t[ind]
      tabl+="<tr><td>"+city[ind]+"</td><td>"+country[ind]+"</td><td>"+yeardetails[ind]+" , "+t[ind]+"</td></tr>"
    tabl+="</table>"
    $("#newevent_time").html tabl
    $("#newevent_time").attr "city",city
    $("#newevent_time").attr "country",country
    $("#newevent_time").attr "time",t
    $("#newevent_time").attr "yeardetails",yeardetails.join(";")
    #t = $("#content #row_ #lihr_"+idx).attr "t"
    #console.log t+" : "+idx

$("#wrapper button#saveevent").live
  click : (e) ->
    msg= $("#wrapper #newevent #newevent_msg").val().trim()
    evname =  $("#wrapper #newevent #event_name").val().trim()
    if msg.length<1
      alert "Please enter some message"
      return
    if evname.length<1
      alert "please enter event name"
      return

    oldobj = {}
    if "events" of localStorage
      oldobj = JSON.parse localStorage.events
    len=0
    for key of oldobj
      len++
    oldobj[len] = {}
    oldobj[len].name = evname
    oldobj[len].desc = msg
    oldobj[len].city = $("#newevent_time").attr "city"
    oldobj[len].country = $("#newevent_time").attr "country"
    oldobj[len].time = $("#newevent_time").attr "time"
    oldobj[len].yeardetails = $("#newevent_time").attr "yeardetails"
    localStorage.events = JSON.stringify oldobj
    $("#event_close").trigger 'click'


$("#event_close").live
  click : (e) ->
    $("#newevent").hide()
    $(".canhide").css "opacity","1"

$("#meeting_details .close").live
  click : ->
    hide_meeting_details()


hide_meeting_details = ->
  $("#meeting_details").slideUp()
  $(".show_meeting_modal").show()
  $(".help_meeting_schedule").show()
  setTimeout (->
    $(".help_meeting_schedule").fadeOut(4000)
  ), 4000


$(".show_meeting_modal span").live
  click: ->
    $("#meeting_details").slideDown()


$("body").live
  keydown: (e) ->
    if e.keyCode == 27
      $("#newevent").hide()
      $(".canhide").css "opacity","1"
      if window.location.search != ""
        hide_meeting_details()




$("#content .row .icons_homedelete .icon_delete").live
  click : (e) ->
    rowindex = parseInt($(e.target).parent().parent().attr("rowindex"))
    oldobj = JSON.parse localStorage.addedLocations

    oldobj = JSON.parse localStorage.addedLocations
    len = 0
    for key of oldobj
      len++
    defaultidx = Number localStorage.default
    if defaultidx > rowindex
      defaultidx--
    delete oldobj[rowindex]
    i = 0
    newobj = {}
    for key, val of oldobj
      key = Number key
      if key > rowindex
        newobj[key-1] = val
      else
        newobj[key] = val

    localStorage.default = defaultidx
    localStorage.addedLocations = JSON.stringify newobj

    renderRows()

$("#content .row .icons_homedelete .icon_home").live
  click : (e) ->
    rowindex = parseInt($(e.target).parent().parent().attr("rowindex"))
    localStorage.default = rowindex
    renderRows()




$("#dateinput").live
  mouseenter : (e) ->
    if $("#error_inputdate").css("display") is "none"
      $("#date_help").show()
  mouseleave :->
    $("#date_help").hide()

$("#setdate_go").live
  click : (e) ->
    #console.log "clicked"
    errormsg = "mm-dd-yyyy format only"

    datestr = $("#dateinput").val().trim()
    window.da = datestr
    unless datestr.length is 10
      $("#error_inputdate").html errormsg
      $("#error_inputdate").show()
      return
    lenofdash = 0

    for key in datestr
      lenofdash++ if key is "-"
    #console.log lenofdash
    unless lenofdash is 2
      $("#error_inputdate").html errormsg
      $("#error_inputdate").show()
      return
    #console.log (datestr.substr(0,2))
    mm = Number datestr.substr(0,2)
    dd = Number datestr.substr(3,2)
    
    year =  datestr.substr(6,4)
    unless year.length is 4
      $("#error_inputdate").html errormsg
      $("#error_inputdate").show()
      return

    #console.log "---"
    year = Number datestr.substr(6,4)
    #console.log mm+" : "+dd+" : "+year
    #console.log (mm >12 or mm<1 or dd<0 or dd>31)
    if (mm >12 or mm<1 or dd<0 or dd>31)
      $("#error_inputdate").html errormsg
      $("#error_inputdate").show()
      return
    $("#error_inputdate").hide()
    #console.log "----"
    ###
    selecteddate.m = mm-1
    selecteddate.d = dd
    selecteddate.year = year
    ###
    options = {}
    options.m = mm-1
    options.d = dd
    options.year = year
    setSelectedDate options

$("#error_inputdate").live
  click : ->
    $("#error_inputdate").slideUp(50)
  focusout : ->
    $("#error_inputdate").hide(500)


$("#content").live
  sortstop : (e,ui) ->
    rowsortstop = ui.item.index() - 2
    if rowsortstart == rowsortstop
      return
    oldobj = JSON.parse localStorage.addedLocations

    startobj = oldobj[rowsortstart]

    for key, val of oldobj
      if rowsortstart < rowsortstop
        if key > rowsortstart and key <= rowsortstop
          oldobj[key-1] = val

    if rowsortstart > rowsortstop
      i=rowsortstart
      while i > rowsortstop
        oldobj[i] = oldobj[i-1]
        i--


    oldobj[rowsortstop] = startobj

    defaultind = Number localStorage.default
    if (defaultind <= rowsortstop and defaultind > rowsortstart) 
      defaultind--
    else if  (defaultind <rowsortstart and defaultind >= rowsortstop )
      defaultind++

    else if defaultind == rowsortstart
      defaultind = rowsortstop

    localStorage.default = defaultind
    localStorage.addedLocations = JSON.stringify oldobj
    renderRows()

  sortstart: (e, ui) ->
    rowsortstart = ui.item.index() - 2

  

$("#wrapper #showevents .eventheader").live

  click : (e) ->
    #console.log "cloic"
    prev = $("#wrapper #showevents #showeventbody").css "display"
    #console.log prev
    unless prev is "none"
      #console.log prev+"--"
      #$("#wrapper #showevents #showeventbody").css "display","none"
      $("#wrapper #showevents #showeventbody").slideUp()

      return
    #console.log prev+" -- should be none"
    unless "events" of localStorage
      $("#wrapper #showevents #showeventbody").html "<h3>No events available, add them first by clicking on the boxes showing time.</h3>"
      #$("#wrapper #showevents #showeventbody").css "display","block"
      $("#wrapper #showevents #showeventbody").slideDown()
      $("body").scrollTo(".showevents")

      return
    oldobj = JSON.parse localStorage.events
    #console.log oldobj
    data = ""
    for key of oldobj
      #console.log oldobj[key]
      city = new Array()
      country = new Array()
      yeardetails = new Array()
      t = new Array()
      city = oldobj[key].city.split(",")
      country  = oldobj[key].country.split(",")
      t  = oldobj[key].time.split(",")
      yeardetails  = oldobj[key].yeardetails.split(";")
      tabl = "<table class='showevent_table table table-striped'><thead><th>City</th><th>Country</th><th>Time</th></thead><tbody>"
      for i of city
        tabl+="<tr><td>"+city[i]+"</td><td>"+country[i]+"</td><td>"+yeardetails[i]+" "+t[i]+"</td></tr>"
      tabl+="</tbody></table>"
      data+= "<h2># "+(parseInt(key)+1)+" "+oldobj[key].name+"<span class='deleteEvent' key='"+key+"'>X&nbsp;</span></h2>"+tabl+"<h3>Description : </h3><p style='padding-left:15px;padding-right:15px;'> "+oldobj[key].desc+"</p><br><hr class='showevents_hr' />"


    if data is ""
      data="<h3>No events available, add them first by clicking on the boxes showing time.</h3>"
    $("#wrapper #showevents #showeventbody").html data
    #$("#wrapper #showevents #showeventbody").css "display","block"
    $("#wrapper #showevents #showeventbody").slideDown()
    $("body").scrollTo("#showevents")

  mouseenter : (e) ->
    $("#event_help").show(75)
  mouseleave : (e) ->
    $("#event_help").hide(75)


$(".deleteEvent").live
  click : (e) ->

    r = confirm "Do you really want to delete this event ? "
    unless r is true
      return
    rowindex = parseInt($(e.target).attr("key"))

    #console.log rowindex

    oldobj = JSON.parse localStorage.events
    len = 0
    for key of oldobj
      len++

    unless rowindex is len-1
      i=rowindex+1
      while i<len
        oldobj[i-1] = oldobj[i]
        i++
    delete oldobj[rowindex]
    localStorage.events = JSON.stringify oldobj
    $("#wrapper #showevents #showeventbody").css "display","none"
    $("#wrapper #showevents .eventheader").trigger "click"



sr_click = (e, k) ->
  if typeof(k) == "undefined"
    k = $(e.target).attr "k"
  offset = $("#lisr_"+k).attr "offset"
  timestr = $("#lisr_"+k).attr "timestr"
  both = $("#lisr_"+k+" span").text()
  botharr = both.split ","
  #botharr[0] country
  #botharr[1] city
  oldobj = JSON.parse localStorage.addedLocations
  len = 0
  key_arr = []
  for key of oldobj
    key_arr += key
    len++

  for key, val of oldobj
    if val['city'].trim() == botharr[1].trim()  and val['country'].trim() == botharr[0].trim()
      return

  newobj = {}
  #i = 0
  #for key, val of oldobj
  #  newobj[i] = val
  #  i += 1
  #console.log JSON.stringify newobj
  #newobj[i] = {}
  #newobj[i].country = botharr[0]
  #newobj[i].city = botharr[1]
  #newobj[i].offset = offset
  #localStorage.addedLocations = JSON.stringify newobj
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


renderRows = (callback) ->
  console.log callback
  oldobj = {}
  if "addedLocations" of localStorage and "default" of localStorage

    #if typeof(localStorage.addedLocaations) == "undefined" or localStorage.addedLocations == "undefined"
    #  oldobj = {}
    #else
    #  oldobj = JSON.parse localStorage.addedLocations
    oldobj = JSON.parse localStorage.addedLocations
  else
    #autodetect
    d = new Date()
    ad_utc = d.getTime() + (d.getTimezoneOffset()*60000)
    ad_offset = (d.getTime()-ad_utc)/3600000
    #console.log "Detected offset  : "+ad_offset+"--"+(ad_offset+"").length

    formattedOffset = convertOffset ad_offset
    #console.log formattedOffset
    pi = tzdata.indexOf formattedOffset
    #console.log window.ttt.indexOf("+05:30")
    #console.log tzdata.indexOf("+05:30")
    #console.log tzdata.length
    #console.log pi
    if pi == -1
      #do something if offset not found in our tz data
      console.log "return"

      return
    else
      console.log "not returning"
    subTillPi = tzdata.substr 0,pi

    prevline = subTillPi.lastIndexOf "\n"
    prevline = 0 if prevline is -1
    presline = tzdata.indexOf "\n",pi
    req = tzdata.substr prevline+1,presline-prevline-1
    #console.log req
    reqArr = req.split ";"
    #console.log reqArr
    newobj = {}

    newobj[0] = {}
    newobj[0].city = reqArr[0]
    newobj[0].country = reqArr[1]
    #newobj[0].standard = reqArr[2]
    floatOffset = convertOffsetToFloat reqArr[3].substr(3)

    if (floatOffset+"").indexOf("-") is -1
      if (floatOffset+"").indexOf("+") is -1
        floatOffset = "+"+floatOffset
    newobj[0].offset = floatOffset
    localStorage.addedLocations = JSON.stringify newobj
    localStorage.default = "0"
    oldobj = JSON.parse localStorage.addedLocations

    #console.log "++++++++++"

  updateUtc()
  console.log callback
  defaultind = localStorage.default

  defaultobj = oldobj[defaultind]
  defaultoffset = parseFloat defaultobj.offset
  row = ""
  for ind of oldobj
    floatOffset = parseFloat oldobj[ind].offset
    #console.log floatOffset+" : "+defaultoffset
    #console.log floatOffset-defaultoffset
    #floatOffset = convertOffsetToFloat offset
    timestr = getNewTime floatOffset
    timearr = timestr.split " "
    timearr[4] = timearr[4].substr(0,5)
    #console.log timearr
    diffoffset = floatOffset-defaultoffset

    #now do hourline operation , and finally add it to "dates"
    diffoffsetstr = diffoffset+""
    hourstart = 1
    #console.log "diffoffsetstr : "+diffoffsetstr
    if diffoffsetstr.indexOf("-") > -1
      diffoffsetstr = diffoffsetstr.substr(1)

      hourstart = 24+diffoffset

    else
      #hourstart = parseInt diffoffsetstr
      hourstart = diffoffset
      #console.log "hourstart +  : "+hourstart

    i=hourstart
    #console.log "__-------------------------------___________________"
    #console.log i


    tempstr = " "
    if (i+"").indexOf(".") > -1
        tempstr = (i+"").substr((i+"").indexOf(".")+1)
        tempstr = parseFloat tempstr
        if tempstr >= 0.5
          tempstr="30"
        else
          tempstr=" "
    #console.log "selected date"
    selectedDateStr = selecteddate.dayInText+" , "+selecteddate.mText+" "+selecteddate.d+" , "+selecteddate.year

    timeextrastr = selecteddate.dayInText+" , "+selecteddate.mText+" "+selecteddate.d+"  "+selecteddate.year
    hourline = "<ul class='hourline_ul'>"
    idx = 0

    iorig = i
    if i is 0 or i is 0.5

      cl = "li_24"
      hourline+=" <li class='"+cl+"' id='lihr_"+idx+"' idx='"+idx+"' t='"+i+"' details='"+selectedDateStr+"' ><div class='span_hl' idx='"+idx+"'><span idx='"+idx+"' class='small' >"+selecteddate.mText+"</span><br><span idx='"+idx+"' class='small' >"+selecteddate.d+"</span></div></li>"

      i = 1
      idx++
    #first loop, till 24-1


    monInNum = getMonth timearr[1],{"type":"num"}
    d = new Date()
    #d.setFullYear timearr[3],monInNum,timearr[2]
    d.setFullYear selecteddate.year,selecteddate.m,selecteddate.d
    #presdate = d.toLocaleString()
    presdate = d+""

    presdatearr = presdate.split " "
    presdatestr = presdatearr[0]+" , "+presdatearr[1]+" "+presdatearr[2]+" , "+presdatearr[3]

    prevdate = new Date()
    prevdate.setFullYear selecteddate.year,selecteddate.m,selecteddate.d

    prevdate.setTime prevdate.getTime() - 86400000
    #prevdate = prevdate.toLocaleString()
    prevdate = prevdate+""
    prevdatearr = prevdate.split " "
    prevdatestr = prevdatearr[0]+" , "+prevdatearr[1]+" "+prevdatearr[2]+" , "+prevdatearr[3]


    d.setTime d.getTime()+86400000

    #d = d.toLocaleString()
    d = d+""
    nextdayarr = d.split " "
    nextDayStr = nextdayarr[0]+" , "+nextdayarr[1]+" "+nextdayarr[2]+" , "+nextdayarr[3]


    dayusedarr = []
    dayusedstr = ""

    if diffoffset >= 0
      dayusedarr = nextdayarr
      dayusedstr = nextDayStr
      datedetailstr = presdatestr
    else
      dayusedarr = presdatearr
      dayusedstr = presdatestr
      datedetailstr = prevdatestr



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


      tval = convertOffsetToFloat(parseInt(i)+":"+tempstr)
      #console.log "tval : "+tval+" ------- "+tempstr


      hourline+=" <li class='"+cl+"' id='lihr_"+idx+"' idx='"+idx+"' t='"+tval+"'  details='"+datedetailstr+"'><div class='span_hl' idx='"+idx+"'><span class='medium' idx='"+idx+"'>"+parseInt(i)+"</span><br><span class='small' idx='"+idx+"'>"+tempstr+"</span></div></li>"

      if tempstr is " "
        hourline = hourline.replace "<span class='medium' idx='"+idx+"'>","<span idx='"+idx+"' >"
      idx++
      i++


    #second, directly put date

    unless hourstart is 0



      cl = "li_24"
      if iorig != 0.5
        hourline+=" <li class='"+cl+"' id='lihr_"+idx+"' idx='"+idx+"' t='"+iorig+"' details='"+dayusedstr+"' ><div class='span_hl' idx='"+idx+"'><span idx='"+idx+"'  class='small'> "+dayusedarr[1]+"</span><br><span idx='"+idx+"' class='small' >"+dayusedarr[2]+"</span></div></li>"
      if timestr is " "
        i=1
      else
        i=1.5
      i=1
      idx++

    # third, loop upto hourstart-1

    #console.log "Before while : "+i
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


      #console.log i
      tval = convertOffsetToFloat(parseInt(i)+":"+tempstr)
      #console.log "tval : "+tval+" ------- "+tempstr

      if diffoffset >=0
        datedetailstr = nextDayStr
      else
        datedetailstr =  presdatestr

      hourline+=" <li class='"+cl+"' id='lihr_"+idx+"' idx='"+idx+"' t='"+tval+"' details='"+datedetailstr+"' ><div class='span_hl' idx='"+idx+"'><span class='medium' idx='"+idx+"'>"+parseInt(i)+"</span><br><span class='small' idx='"+idx+"'>"+tempstr+"</span></div></li>"
      if tempstr is " "
        hourline = hourline.replace "<span class='medium' idx='"+idx+"'>","<span idx='"+idx+"' >"
      i++
      idx++

    hourline+="</ul>"

    sym = ""
    if diffoffset > 0
      sym = "+"


    row+= "<div class='row' id='row_"+ind+"' rowindex='"+ind+"' time='"+timearr[4]+"' original_offset='"+oldobj[ind].offset+"' ><div class='tzdetails'><div class='offset'>"+sym+(floatOffset-defaultoffset)+"<br><span class='small' >Hours</span></div><div class='location'><span class='city'>"+oldobj[ind].city+"</span><br><span class='country'>"+oldobj[ind].country+"</span></div><div class='timedata'><span class='time'>"+timearr[4]+"</span><br><span class='timeextra'>"+timeextrastr+"</span></div></div><div class='dates'>"+hourline+"</div></div> "

  #$("#content").html "<div id='vband'></div><div id='selectedband'></div>"
  $("#content").html row
  #$("#content .row .dates li").first().append "<div id='vband'></div><div id='selectedband'></div>"
  $("#content").prepend "<div id='vband'></div><div id='selectedband'></div>"
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
  #console.log "left : "+left
  left = left*28 + 322
  #console.log left+" : "+height
  $("#selectedband").css "height",height
  $("#selectedband").css "left",left
  left = parseInt($("#selectedband").css("left"))
  $("#vband").css "left",(left-2)
  $("#vband").css "height",$("#selectedband").css("height")
  $("#content").sortable({'containment':'parent', 'items':'.row'})
  #if added_locations_status == "undefined"
  #  generate_meeting_link()
  
  console.log callback
  if typeof(callback) == "function"
    console.log "calling"
    callback()
  else
    console.log callback
    console.log "not calling"
  if callback == "a"
    console.log "yes a"
    generate_meeting_link()
  else
    console.log "not a"
    console.log callback

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


getMonth = (mon,options) ->
  month = new Array()
  month[0]="Jan"
  month[1]="Feb"
  month[2]="Mar"
  month[3]="Apr"
  month[4]="May"
  month[5]="Jun"
  month[6]="Jul"
  month[7]="Aug"
  month[8]="Sep"
  month[9]="Oct"
  month[10]="Nov"
  month[11]="Dec"
  if options.type is "num"
    for m of month
      if month[m] is mon
        return m
  else if options.type is "str"
    return month[mon]

setSelectedDate = (options) ->
#  HERE IN OPTIONS, SEND MONTH IN ZERO INDEXED FORMAT
  if options
    selecteddate = options
    selecteddate.mText = getMonth selecteddate.m,{"type":"str"}
    #dnew = new Date(selecteddate.m+"-"+selecteddate.d+"-"+selecteddate.year)
    dnew = new Date()
    dnew.setMonth(selecteddate.m)
    dnew.setDate(selecteddate.d)
    dnew.setFullYear(selecteddate.year) 
    dnew = dnew.toLocaleString()
    dnewarr = dnew.split " "
    selecteddate.dayInText = dnewarr[0]
    


  else
    d = new Date()
    selecteddate.m = d.getMonth()
    selecteddate.d = d.getDate()
    selecteddate.year = d.getYear()+1900
    selecteddate.mText = getMonth selecteddate.m,{"type":"str"}
    #dnew = new Date((parseInt(selecteddate.m+1))+"-"+selecteddate.d+"-"+selecteddate.year)
    dnew = new Date()
    dnew.setMonth(selecteddate.m)
    dnew.setDate(selecteddate.d)
    dnew.setFullYear(selecteddate.year) 
    dnew = dnew.toLocaleString()
    dnewarr = dnew.split " "
    selecteddate.dayInText = dnewarr[0]
  renderRows()

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
