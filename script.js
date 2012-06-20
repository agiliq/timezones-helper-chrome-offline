(function() {
  var convertOffset, convertOffsetToFloat, convsdfsertOffset, getLocations, getMonth, getNewTime, k, locations, origcities, renderRows, rowsortstart, rowsortstop, selecteddate, setSelectedDate, sr_click, tzdata, tzdatalower, updateUtc, utc,
    _this = this;

  origcities = "";

  tzdata = "";

  tzdatalower = "";

  k = 0;

  locations = "";

  utc = 0;

  selecteddate = {};

  rowsortstart = "";

  rowsortstop = "";

  $(document).ready(function() {
    var bombayoff, bt, d, datearr, dstr, localoffset, localtime, nd, ndarr, ndstr;
    updateUtc();
    d = new Date();
    dstr = d.toLocaleString();
    datearr = dstr.split(" ");
    localtime = d.getTime();
    localoffset = d.getTimezoneOffset() * 60000;
    utc = localtime + localoffset;
    bombayoff = 5.5;
    bt = utc + (3600000 * bombayoff);
    nd = new Date(bt);
    ndstr = nd.toLocaleString();
    ndarr = ndstr.split(" ");
    setSelectedDate();
    /*
      $.ajax
          url : "tz/cities.csv"
          success : (cities) ->
            origcities = cities.toLowerCase()
            #console.log "cities loaded successfully"
          error : (e) ->
            #console.log "Error loading cities"
    */
    return $.ajax({
      url: "tz/tz.csv",
      success: function(tz) {
        window.ttt = tz;
        tzdata = tz;
        tzdatalower = tz.toLowerCase();
        return renderRows();
      },
      error: function(e) {}
    });
  });

  $("#search_input").live({
    keyup: function(e) {
      var st;
      st = $(e.target).val().trim();
      st.toLowerCase();
      if (st.length < 1) {
        $("#search_result").hide(200);
        return;
      }
      locations = "<br><ul class='searchresult_ul'>";
      k = 0;
      $("#search_result").html("");
      updateUtc();
      getLocations(0, st);
      $("#search_result").show();
      return $("#search_result").html(locations);
    },
    focusout: function() {
      return $("#search_result").hide(1000);
    }
  });

  $("ul.searchresult_ul").live({
    click: function(e) {
      return sr_click(e);
    }
  });

  $("#content .row .dates ul li").live({
    mouseenter: function(e) {
      var idx, left;
      $(".row .dates li").first().css("position", "relative");
      idx = $(e.target).attr("idx");
      $("#vband").attr("idx", idx);
      $("#vband").css("height", parseInt($("#content .row").length) * 72 - 41);
      left = parseInt(idx) * 28;
      return $("#vband").css("left", left - 2);
    }
  });

  $("#content .row .dates").live({
    mouseleave: function(e) {
      var left;
      left = parseInt($("#selectedband").css("left"));
      return $("#vband").css("left", left - 2);
    }
  });

  $("#vband").live({
    click: function(e) {
      var city, country, ele, idx, ind, t, tText, tabl, yeardetails, _i, _len, _ref;
      $(".canhide").css("opacity", "0.1");
      idx = $(e.target).attr("idx");
      if (idx === void 0) return;
      t = new Array();
      city = new Array();
      country = new Array();
      yeardetails = new Array();
      _ref = $(".row");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ele = _ref[_i];
        tText = convertOffset($("#" + ele.id + " #lihr_" + idx).attr("t"));
        t.push(tText.substr(1));
        city.push($("#" + ele.id + " .city").text());
        country.push($("#" + ele.id + " .country").text());
        yeardetails.push($("#" + ele.id + " #lihr_" + idx).attr("details"));
      }
      $("#newevent").show();
      $("#newevent_time").text("");
      $("#newevent_msg").text("");
      $("#event_name").text("");
      tabl = "<table id='newevent_table' ><thead><th>city</th><th>country</th><th>Time</th></thead>";
      for (ind in t) {
        tabl += "<tr><td>" + city[ind] + "</td><td>" + country[ind] + "</td><td>" + yeardetails[ind] + " , " + t[ind] + "</td></tr>";
      }
      tabl += "</table>";
      $("#newevent_time").html(tabl);
      $("#newevent_time").attr("city", city);
      $("#newevent_time").attr("country", country);
      $("#newevent_time").attr("time", t);
      return $("#newevent_time").attr("yeardetails", yeardetails.join(";"));
    }
  });

  $("#wrapper button#saveevent").live({
    click: function(e) {
      var evname, key, len, msg, oldobj;
      msg = $("#wrapper #newevent #newevent_msg").val().trim();
      evname = $("#wrapper #newevent #event_name").val().trim();
      if (msg.length < 1) {
        alert("Please enter some message");
        return;
      }
      if (evname.length < 1) {
        alert("please enter event name");
        return;
      }
      oldobj = {};
      if ("events" in localStorage) oldobj = JSON.parse(localStorage.events);
      len = 0;
      for (key in oldobj) {
        len++;
      }
      oldobj[len] = {};
      oldobj[len].name = evname;
      oldobj[len].desc = msg;
      oldobj[len].city = $("#newevent_time").attr("city");
      oldobj[len].country = $("#newevent_time").attr("country");
      oldobj[len].time = $("#newevent_time").attr("time");
      oldobj[len].yeardetails = $("#newevent_time").attr("yeardetails");
      localStorage.events = JSON.stringify(oldobj);
      return $("#event_close").trigger('click');
    }
  });

  $("#event_close").live({
    click: function(e) {
      $("#newevent").hide();
      return $(".canhide").css("opacity", "1");
    }
  });

  $("#content .row .icons_homedelete .icon_delete").live({
    click: function(e) {
      var defaultind, i, key, len, oldobj, rowindex;
      rowindex = parseInt($(e.target).parent().parent().attr("rowindex"));
      oldobj = JSON.parse(localStorage.addedLocations);
      len = 0;
      for (key in oldobj) {
        len++;
      }
      i = rowindex + 1;
      while (i < len) {
        oldobj[i - 1] = oldobj[i];
        i++;
      }
      delete oldobj[i - 1];
      localStorage.addedLocations = JSON.stringify(oldobj);
      defaultind = parseInt(localStorage["default"]);
      if (defaultind === (i - 1)) localStorage["default"] = defaultind - 1;
      return renderRows();
    }
  });

  $("#content .row .icons_homedelete .icon_home").live({
    click: function(e) {
      var rowindex;
      rowindex = parseInt($(e.target).parent().parent().attr("rowindex"));
      /*  
      oldobj = JSON.parse localStorage.addedLocations
      tempobj = oldobj[rowindex]
      oldobj[rowindex] = oldobj[0]
      oldobj[0] = tempobj
      localStorage.addedLocations = JSON.stringify oldobj
      renderRows()
      */
      localStorage["default"] = rowindex;
      return renderRows();
    }
  });

  $("#dateinput").live({
    mouseenter: function(e) {
      if ($("#error_inputdate").css("display") === "none") {
        return $("#date_help").show();
      }
    },
    mouseleave: function() {
      return $("#date_help").hide();
    }
  });

  $("#setdate_go").live({
    click: function(e) {
      var datestr, dd, errormsg, key, lenofdash, mm, options, year, _i, _len;
      errormsg = "mm-dd-yyyy format only";
      datestr = $("#dateinput").val().trim();
      if (datestr.length !== 10) {
        $("#error_inputdate").html(errormsg);
        $("#error_inputdate").show();
        return;
      }
      lenofdash = 0;
      for (_i = 0, _len = datestr.length; _i < _len; _i++) {
        key = datestr[_i];
        if (key === "-") lenofdash++;
      }
      if (lenofdash !== 2) {
        $("#error_inputdate").html(errormsg);
        $("#error_inputdate").show();
        return;
      }
      mm = parseFloat(datestr.substr(0, 2));
      mm = parseInt(mm);
      dd = parseInt(datestr.substr(3, 2));
      year = datestr.substr(6, 4);
      if (year.length !== 4) {
        $("#error_inputdate").html(errormsg);
        $("#error_inputdate").show();
        return;
      }
      year = parseInt(datestr.substr(6, 4));
      if (mm > 12 || mm < 1 || dd < 0 || dd > 31) {
        $("#error_inputdate").html(errormsg);
        $("#error_inputdate").show();
        return;
      }
      $("#error_inputdate").hide();
      /*
          selecteddate.m = mm-1
          selecteddate.d = dd
          selecteddate.year = year
      */
      options = {};
      options.m = mm - 1;
      options.d = dd;
      options.year = year;
      return setSelectedDate(options);
    }
  });

  $("#error_inputdate").live({
    click: function() {
      return $("#error_inputdate").slideUp(500);
    },
    focusout: function() {
      return $("#error_inputdate").hide(500);
    }
  });

  $("#content").live({
    sortstop: function(e, ui) {
      var defaultind, oldobj, tempobj;
      rowsortstop = ui.item.index();
      defaultind = localStorage["default"];
      if (defaultind === rowsortstart + "") {
        defaultind = rowsortstop;
      } else {
        if (defaultind === rowsortstop + "") defaultind = rowsortstart;
      }
      oldobj = JSON.parse(localStorage.addedLocations);
      tempobj = oldobj[rowsortstart];
      oldobj[rowsortstart] = oldobj[rowsortstop];
      oldobj[rowsortstop] = tempobj;
      localStorage.addedLocations = JSON.stringify(oldobj);
      localStorage["default"] = defaultind;
      return renderRows();
    },
    sortstart: function(e, ui) {
      return rowsortstart = ui.item.index();
    }
  });

  $("#wrapper #showevents .eventheader").live({
    click: function(e) {
      var city, country, data, i, key, oldobj, prev, t, tabl, yeardetails;
      prev = $("#wrapper #showevents #showeventbody").css("display");
      if (prev !== "none") {
        $("#wrapper #showevents #showeventbody").css("display", "none");
        return;
      }
      if (!("events" in localStorage)) {
        $("#wrapper #showevents #showeventbody").html("<h3>No events available, add them first by clicking on required dates</h3>");
        $("#wrapper #showevents #showeventbody").css("display", "block");
        return;
      }
      oldobj = JSON.parse(localStorage.events);
      data = "";
      for (key in oldobj) {
        city = new Array();
        country = new Array();
        yeardetails = new Array();
        t = new Array();
        city = oldobj[key].city.split(",");
        country = oldobj[key].country.split(",");
        t = oldobj[key].time.split(",");
        yeardetails = oldobj[key].yeardetails.split(";");
        tabl = "<table class='showevent_table'><thead><th>City</th><th>Country</th><th>Time</th></thead><tbody>";
        for (i in city) {
          tabl += "<tr><td>" + city[i] + "</td><td>" + country[i] + "</td><td>" + yeardetails[i] + " " + t[i] + "</td></tr>";
        }
        tabl += "</tbody></table>";
        data += "<h2># " + (parseInt(key) + 1) + " " + oldobj[key].name + "<span class='deleteEvent' key='" + key + "'>X</span></h2>" + tabl + "<h3>Description : </h3> " + oldobj[key].desc + "<br><hr class='showevents_hr' />";
      }
      if (data === "") {
        data = "<h3>No events available, add them first by clicking on required dates</h3>";
      }
      $("#wrapper #showevents #showeventbody").html(data);
      return $("#wrapper #showevents #showeventbody").css("display", "block");
    },
    mouseenter: function(e) {
      return $("#event_help").show(75);
    },
    mouseleave: function(e) {
      return $("#event_help").hide(75);
    }
  });

  $(".deleteEvent").live({
    click: function(e) {
      var i, key, len, oldobj, r, rowindex;
      r = confirm("Do you really want to delete this event ? ");
      if (r !== true) return;
      rowindex = parseInt($(e.target).attr("key"));
      oldobj = JSON.parse(localStorage.events);
      len = 0;
      for (key in oldobj) {
        len++;
      }
      if (rowindex !== len - 1) {
        i = rowindex + 1;
        while (i < len) {
          oldobj[i - 1] = oldobj[i];
          i++;
        }
      }
      delete oldobj[rowindex];
      localStorage.events = JSON.stringify(oldobj);
      $("#wrapper #showevents #showeventbody").css("display", "none");
      return $("#wrapper #showevents .eventheader").trigger("click");
    }
  });

  $("lKNHi span").live({
    click: function(e) {},
    mouseover: function() {}
  });

  $("ulsss").live({
    click: function(e) {
      return sr_click(e);
    },
    mouseover: function() {}
  });

  sr_click = function(e) {
    var both, botharr, key, len, offset, oldobj, timestr;
    k = $(e.target).attr("k");
    offset = $("#lisr_" + k).attr("offset");
    timestr = $("#lisr_" + k).attr("timestr");
    both = $("#lisr_" + k + " span").text();
    botharr = both.split(",");
    oldobj = JSON.parse(localStorage.addedLocations);
    len = 0;
    for (key in oldobj) {
      len++;
    }
    oldobj[len] = {};
    oldobj[len].country = botharr[0];
    oldobj[len].city = botharr[1];
    oldobj[len].offset = offset;
    localStorage.addedLocations = JSON.stringify(oldobj);
    return renderRows();
  };

  getLocations = function(ind, st) {
    var finaloff, first, offset, pi, presline, prevline, req, reqArr, second, subTillPi, timearr, timestr;
    if (k > 7) {
      locations += "</ul>";
      return;
    }
    k++;
    ind = parseInt(ind);
    if (ind === 0) {
      ind = 0;
    } else {
      ind++;
    }
    pi = parseInt(tzdatalower.indexOf(st, ind));
    if (pi === -1) {
      locations += "</ul>";
      return;
    }
    subTillPi = tzdatalower.substr(0, pi);
    prevline = parseInt(subTillPi.lastIndexOf("\n"));
    if (prevline === -1) {
      prevline = 0;
    } else if (prevline === 0) {
      prevline = 0;
    } else {
      prevline++;
    }
    presline = parseInt(tzdatalower.indexOf("\n", pi));
    req = tzdata.substr(prevline, presline - prevline);
    reqArr = req.split(";");
    offset = reqArr[3];
    finaloff = "";
    if (offset.length === 9) {
      offset = offset.substr(3, 9);
      first = offset.substr(0, 3);
      second = offset.substr(4, 2) / 60;
      second = (second + "").substr(1);
      finaloff = parseFloat(first + second);
    } else {
      finaloff = 0;
    }
    timestr = getNewTime(finaloff);
    timearr = timestr.split(" ");
    timearr[4] = timearr[4].substr(0, 5);
    locations += "<li class='searchresult_li' offset='" + finaloff + "' timestr='" + timestr + "' id='lisr_" + k + "' k='" + k + "'><span class='litz' k='" + k + "'>" + reqArr[1] + " , " + reqArr[0] + ",</span><span class='litime' k='" + k + "'>" + timearr[4] + "</span></li>";
    return getLocations(presline, st);
  };

  renderRows = function() {
    var ad_offset, ad_utc, cl, d, datedetailstr, dayusedarr, dayusedstr, defaultind, defaultobj, defaultoffset, diffoffset, diffoffsetstr, floatOffset, formattedOffset, height, hourline, hourstart, i, icons_homedelete, idx, ind, iorig, left, monInNum, newobj, nextDayStr, nextdayarr, oldobj, pi, presdate, presdatearr, presdatestr, presline, prevdate, prevdatearr, prevdatestr, prevline, req, reqArr, row, selectedDateStr, subTillPi, sym, tempstr, timearr, timeextrastr, timestr, tval;
    oldobj = {};
    if ("addedLocations" in localStorage && "default" in localStorage) {
      oldobj = JSON.parse(localStorage.addedLocations);
    } else {
      d = new Date();
      ad_utc = d.getTime() + (d.getTimezoneOffset() * 60000);
      ad_offset = (d.getTime() - ad_utc) / 3600000;
      formattedOffset = convertOffset(ad_offset);
      pi = tzdata.indexOf(formattedOffset);
      if (pi === -1) return;
      subTillPi = tzdata.substr(0, pi);
      prevline = subTillPi.lastIndexOf("\n");
      if (prevline === -1) prevline = 0;
      presline = tzdata.indexOf("\n", pi);
      req = tzdata.substr(prevline + 1, presline - prevline - 1);
      reqArr = req.split(";");
      newobj = {};
      newobj[0] = {};
      newobj[0].city = reqArr[0];
      newobj[0].country = reqArr[1];
      floatOffset = convertOffsetToFloat(reqArr[3].substr(3));
      if ((floatOffset + "").indexOf("-" === -1)) {
        if ((floatOffset + "").indexOf("+" === -1)) {
          floatOffset = "+" + floatOffset;
        }
      }
      newobj[0].offset = floatOffset;
      localStorage.addedLocations = JSON.stringify(newobj);
      localStorage["default"] = "0";
      oldobj = JSON.parse(localStorage.addedLocations);
    }
    updateUtc();
    /*
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
    */
    defaultind = localStorage["default"];
    defaultobj = oldobj[defaultind];
    defaultoffset = parseFloat(defaultobj.offset);
    row = "";
    for (ind in oldobj) {
      floatOffset = parseFloat(oldobj[ind].offset);
      timestr = getNewTime(floatOffset);
      timearr = timestr.split(" ");
      timearr[4] = timearr[4].substr(0, 5);
      diffoffset = floatOffset - defaultoffset;
      diffoffsetstr = diffoffset + "";
      hourstart = 1;
      if (diffoffsetstr.indexOf("-") > -1) {
        diffoffsetstr = diffoffsetstr.substr(1);
        hourstart = 24 + diffoffset;
      } else {
        hourstart = diffoffset;
      }
      i = hourstart;
      tempstr = " ";
      if ((i + "").indexOf(".") > -1) {
        tempstr = (i + "").substr((i + "").indexOf(".") + 1);
        tempstr = parseFloat(tempstr);
        if (tempstr >= 0.5) {
          tempstr = "30";
        } else {
          tempstr = " ";
        }
      }
      selectedDateStr = selecteddate.dayInText + " , " + selecteddate.mText + " " + selecteddate.d + " , " + selecteddate.year;
      timeextrastr = selecteddate.dayInText + " , " + selecteddate.mText + " " + selecteddate.d + "  " + selecteddate.year;
      hourline = "<ul class='hourline_ul'>";
      idx = 0;
      iorig = i;
      if (i === 0 || i === 0.5) {
        cl = "li_24";
        hourline += " <li class='" + cl + "' id='lihr_" + idx + "' idx='" + idx + "' t='" + i + "' details='" + selectedDateStr + "' ><div class='span_hl' idx='" + idx + "'><span idx='" + idx + "' class='small' >" + selecteddate.mText + "</span><br><span idx='" + idx + "' class='small' >" + selecteddate.d + "</span></div></li>";
        i = 1;
        idx++;
      }
      monInNum = getMonth(timearr[1], {
        "type": "num"
      });
      d = new Date();
      d.setFullYear(selecteddate.year, selecteddate.m, selecteddate.d);
      presdate = d.toLocaleString();
      presdatearr = presdate.split(" ");
      presdatestr = presdatearr[0] + " , " + presdatearr[1] + " " + presdatearr[2] + " , " + presdatearr[3];
      prevdate = new Date();
      prevdate.setFullYear(selecteddate.year, selecteddate.m, selecteddate.d);
      prevdate.setTime(prevdate.getTime() - 86400000);
      prevdate = prevdate.toLocaleString();
      prevdatearr = prevdate.split(" ");
      prevdatestr = prevdatearr[0] + " , " + prevdatearr[1] + " " + prevdatearr[2] + " , " + prevdatearr[3];
      d.setTime(d.getTime() + 86400000);
      d = d.toLocaleString();
      nextdayarr = d.split(" ");
      nextDayStr = nextdayarr[0] + " , " + nextdayarr[1] + " " + nextdayarr[2] + " , " + nextdayarr[3];
      dayusedarr = [];
      dayusedstr = "";
      if (diffoffset >= 0) {
        dayusedarr = nextdayarr;
        dayusedstr = nextDayStr;
        datedetailstr = presdatestr;
      } else {
        dayusedarr = presdatearr;
        dayusedstr = presdatestr;
        datedetailstr = prevdatestr;
      }
      while (i < 24) {
        if (i < 6) {
          cl = "li_n";
        } else if (i > 5 && i < 8) {
          cl = "li_m";
        } else if (i > 7 && i < 19) {
          cl = "li_d";
        } else if (i > 18 && i < 22) {
          cl = "li_e";
        } else {
          cl = "li_n";
        }
        tval = convertOffsetToFloat(parseInt(i) + ":" + tempstr);
        hourline += " <li class='" + cl + "' id='lihr_" + idx + "' idx='" + idx + "' t='" + tval + "'  details='" + datedetailstr + "'><div class='span_hl' idx='" + idx + "'><span class='medium' idx='" + idx + "'>" + parseInt(i) + "</span><br><span class='small' idx='" + idx + "'>" + tempstr + "</span></div></li>";
        if (tempstr === " ") {
          hourline = hourline.replace("<span class='medium' idx='" + idx + "'>", "<span idx='" + idx + "' >");
        }
        idx++;
        i++;
      }
      if (hourstart !== 0) {
        cl = "li_24";
        if (iorig !== 0.5) {
          hourline += " <li class='" + cl + "' id='lihr_" + idx + "' idx='" + idx + "' t='" + iorig + "' details='" + dayusedstr + "' ><div class='span_hl' idx='" + idx + "'><span idx='" + idx + "'  class='small'> " + dayusedarr[1] + "</span><br><span idx='" + idx + "' class='small' >" + dayusedarr[2] + "</span></div></li>";
        }
        if (timestr === " ") {
          i = 1;
        } else {
          i = 1.5;
        }
        i = 1;
        idx++;
      }
      while (i < parseInt(hourstart)) {
        if (i < 6) {
          cl = "li_n";
        } else if (i > 5 && i < 8) {
          cl = "li_m";
        } else if (i > 7 && i < 19) {
          cl = "li_d";
        } else if (i > 18 && i < 22) {
          cl = "li_e";
        } else {
          cl = "li_n";
        }
        tval = convertOffsetToFloat(parseInt(i) + ":" + tempstr);
        if (diffoffset >= 0) {
          datedetailstr = nextDayStr;
        } else {
          datedetailstr = presdatestr;
        }
        hourline += " <li class='" + cl + "' id='lihr_" + idx + "' idx='" + idx + "' t='" + tval + "' details='" + datedetailstr + "' ><div class='span_hl' idx='" + idx + "'><span class='medium' idx='" + idx + "'>" + parseInt(i) + "</span><br><span class='small' idx='" + idx + "'>" + tempstr + "</span></div></li>";
        if (tempstr === " ") {
          hourline = hourline.replace("<span class='medium' idx='" + idx + "'>", "<span idx='" + idx + "' >");
        }
        i++;
        idx++;
      }
      hourline += "</ul>";
      sym = "";
      if (diffoffset > 0) sym = "+";
      row += "<div class='row' id='row_" + ind + "' rowindex='" + ind + "' time='" + timearr[4] + "' ><div class='tzdetails'><div class='offset'>" + sym + (floatOffset - defaultoffset) + "<br><span class='small' >Hours</span></div><div class='location'><span class='city'>" + oldobj[ind].city + "</span><br><span class='country'>" + oldobj[ind].country + "</span></div><div class='timedata'><span class='time'>" + timearr[4] + "</span><br><span class='timeextra'>" + timeextrastr + "</span></div></div><div class='dates'>" + hourline + "</div></div> ";
    }
    $("#content").html(row);
    $("#content .row .dates li").first().append("<div id='vband'></div><div id='selectedband'></div>");
    icons_homedelete = "<div class='icons_homedelete'><div class='icon_delete'>x</div><div class='icon_home'  ></div></div>";
    $("#content .row").append(icons_homedelete);
    defaultind = parseInt(localStorage["default"]);
    $("#content #row_" + defaultind + " .icons_homedelete").html("");
    $("#content #row_" + defaultind + " .tzdetails .offset").html("<div class='homeicon'></div>");
    $(".row .dates li").first().css("position", "relative");
    height = parseInt($("#content .row").length) * 72 - 41;
    left = $("#content #row_" + defaultind).attr("time");
    left = left.substr(0, left.indexOf(":"));
    left = parseInt(left);
    left = left * 28;
    $("#selectedband").css("height", height);
    $("#selectedband").css("left", left);
    left = parseInt($("#selectedband").css("left"));
    $("#vband").css("left", left - 2);
    $("#vband").css("height", $("#selectedband").css("height"));
    return $("#content").sortable();
  };

  convertOffsetToFloat = function(str) {
    var first, second;
    first = str.substr(0, str.indexOf(":"));
    second = parseFloat(str.substr(str.indexOf(":") + 1)) / 60;
    second = (second + "").substr((second + "").indexOf(".") + 1);
    return parseFloat(first + "." + second);
  };

  convertOffset = function(ad_offset) {
    var first, second, sign, str;
    sign = "";
    str = "";
    first = "";
    second = "";
    ad_offset = ad_offset + "";
    if (ad_offset.indexOf("-") > -1) {
      sign = "-";
      str = ad_offset.substr(1);
    } else {
      sign = "+";
      str = ad_offset;
    }
    if (str.indexOf(".") > -1) {
      first = str.substr(0, str.indexOf("."));
      second = parseInt(str.substr(str.indexOf(".") + 1)) * 6 + "";
      if (first.length === 1) first = "0" + first;
      if (second.length === 1) second = "0" + second;
    } else {
      if (str.length === 1) {
        first = "0" + str;
      } else {
        first = str;
      }
      second = "00";
    }
    return sign + first + ":" + second;
  };

  convsdfsertOffset = function(offset) {
    var first, newlocaloffset, second, sign;
    newlocaloffset = offset;
    offset = offset + "";
    first = "";
    second = "";
    if (offset.indexOf(".") > -1) {
      if (offset.indexOf("-") > -1) {
        first = offset.substr(1, 2);
        if (first.length === 1) first = "0" + first;
        second = parseInt(offset.substr(4, 5)) * 60;
        if (second.length === 1) second = second + "0";
        sign = "-";
      } else {
        first = offset.substr(0, 1);
        if (first.length === 1) first = "0" + first;
        second = parseInt(offset.substr(3, 4)) * 60;
        if (second.length === 1) second = second + "0";
        sign = "+";
      }
    } else {
      if (offset.indexOf("-") > -1) {
        sign = "-";
        if (offset.length === 3) {
          first = offset.substr(1, 2);
        } else {
          first = "0" + offset.substr(1, 1);
        }
        second = "00";
      } else {
        sign = "+";
        if (offset.length === 2) {
          first = offset.substr(0, 2);
        } else {
          first = offset.substr(0, 1);
        }
        second = "00";
      }
    }
    return $("body").append("<h1>" + first + " : " + second + "</h1>");
  };

  getMonth = function(mon, options) {
    var m, month;
    month = new Array();
    month[0] = "Jan";
    month[1] = "Feb";
    month[2] = "Mar";
    month[3] = "Apr";
    month[4] = "May";
    month[5] = "Jun";
    month[6] = "Jul";
    month[7] = "Aug";
    month[8] = "Sep";
    month[9] = "Oct";
    month[10] = "Nov";
    month[11] = "Dec";
    if (options.type === "num") {
      for (m in month) {
        if (month[m] === mon) return m;
      }
    } else if (options.type === "str") {
      return month[mon];
    }
  };

  setSelectedDate = function(options) {
    var d, dnew, dnewarr;
    if (options) {
      selecteddate = options;
      selecteddate.mText = getMonth(selecteddate.m, {
        "type": "str"
      });
      dnew = new Date(selecteddate.m + "-" + selecteddate.d + "-" + selecteddate.year);
      dnew = dnew.toLocaleString();
      dnewarr = dnew.split(" ");
      selecteddate.dayInText = dnewarr[0];
    } else {
      d = new Date();
      selecteddate.m = d.getMonth();
      selecteddate.d = d.getDate();
      selecteddate.year = d.getYear() + 1900;
      selecteddate.mText = getMonth(selecteddate.m, {
        "type": "str"
      });
      dnew = new Date((parseInt(selecteddate.m + 1)) + "-" + selecteddate.d + "-" + selecteddate.year);
      dnew = dnew.toLocaleString();
      dnewarr = dnew.split(" ");
      selecteddate.dayInText = dnewarr[0];
    }
    return renderRows();
  };

  updateUtc = function() {
    var d, datearr, dstr, localoffset, localtime;
    d = new Date();
    dstr = d.toLocaleString();
    datearr = dstr.split(" ");
    localtime = d.getTime();
    localoffset = d.getTimezoneOffset() * 60000;
    return utc = localtime + localoffset;
  };

  getNewTime = function(offset) {
    var nd, ndstr, newtime;
    newtime = utc + (3600000 * offset);
    nd = new Date(newtime);
    ndstr = nd.toLocaleString();
    return ndstr;
  };

}).call(this);
