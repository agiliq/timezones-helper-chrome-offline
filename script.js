(function() {
  var convertOffset, convertOffsetToFloat, convsdfsertOffset, getLocations, getMonth, getNewTime, k, locations, origcities, renderRows, sr_click, tzdata, tzdatalower, updateUtc, utc,
    _this = this;

  origcities = "";

  tzdata = "";

  tzdatalower = "";

  k = 0;

  locations = "";

  utc = 0;

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
    $.ajax({
      url: "tz/cities.csv",
      success: function(cities) {
        return origcities = cities.toLowerCase();
      },
      error: function(e) {
        return console.log("Error loading cities");
      }
    });
    return $.ajax({
      url: "tz/tz.csv",
      success: function(tz) {
        window.ttt = tz;
        tzdata = tz;
        tzdatalower = tz.toLowerCase();
        console.log("tzdata loaded successfully");
        return renderRows();
      },
      error: function(e) {
        return console.log("Error loading tz data");
      }
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
      console.log("-------li---------");
      return sr_click(e);
    }
  });

  $("#content .row .dates ul li").live({
    mouseenter: function(e) {
      var idx, left;
      $(".row .dates li").first().css("position", "relative");
      idx = $(e.target).attr("idx");
      $("#vband").css("height", parseInt($("#content .row").length) * 72 - 41);
      left = parseInt(idx) * 28;
      $("#vband").css("left", left - 2);
      return console.log(left + " : " + idx);
    }
  });

  $("#content .row .dates").live({
    mouseleave: function(e) {
      var left;
      left = parseInt($("#selectedband").css("left"));
      return $("#vband").css("left", left - 2);
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
      console.log(rowindex);
      localStorage["default"] = rowindex;
      return renderRows();
    }
  });

  $("lKNHi span").live({
    click: function(e) {
      return console.log("--------span------------------");
    },
    mouseover: function() {
      return console.log("----------");
    }
  });

  $("ulsss").live({
    click: function(e) {
      console.log("-------ul-------------");
      return sr_click(e);
    },
    mouseover: function() {
      return console.log("--");
    }
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
    var ad_offset, ad_utc, cl, d, defaultind, defaultobj, defaultoffset, diffoffset, diffoffsetstr, floatOffset, formattedOffset, height, hourline, hourstart, i, icons_homedelete, idx, ind, left, monInNum, newobj, nextdayarr, oldobj, pi, presline, prevline, req, reqArr, row, subTillPi, tempstr, timearr, timestr;
    oldobj = {};
    if ("addedLocations" in localStorage && "default" in localStorage) {
      oldobj = JSON.parse(localStorage.addedLocations);
    } else {
      d = new Date();
      ad_utc = d.getTime() + (d.getTimezoneOffset() * 60000);
      ad_offset = (d.getTime() - ad_utc) / 3600000;
      console.log("Detected offset  : " + ad_offset + "--" + (ad_offset + "").length);
      formattedOffset = convertOffset(ad_offset);
      console.log(formattedOffset);
      pi = tzdata.indexOf(formattedOffset);
      console.log(tzdata.indexOf("+05:30"));
      console.log(tzdata.length);
      console.log(pi);
      if (pi === -1) return;
      subTillPi = tzdata.substr(0, pi);
      prevline = subTillPi.lastIndexOf("\n");
      if (prevline === -1) prevline = 0;
      presline = tzdata.indexOf("\n", pi);
      req = tzdata.substr(prevline + 1, presline - prevline - 1);
      console.log(req);
      reqArr = req.split(";");
      console.log(reqArr);
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
      console.log("++++++++++");
    }
    console.log("pp");
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
      console.log(floatOffset + " : " + defaultoffset);
      console.log(floatOffset - defaultoffset);
      timestr = getNewTime(floatOffset);
      timearr = timestr.split(" ");
      timearr[4] = timearr[4].substr(0, 5);
      console.log(timearr);
      diffoffset = floatOffset - defaultoffset;
      diffoffsetstr = diffoffset + "";
      hourstart = 1;
      console.log("diffoffsetstr : " + diffoffsetstr);
      if (diffoffsetstr.indexOf("-") > -1) {
        diffoffsetstr = diffoffsetstr.substr(1);
        hourstart = 24 + diffoffset;
        console.log("houstart  : " + hourstart);
      } else {
        hourstart = diffoffset;
        console.log("hourstart +  : " + hourstart);
      }
      i = hourstart;
      console.log("__-------------------------------___________________");
      console.log(i);
      tempstr = "";
      if ((i + "").indexOf(".") > -1) {
        tempstr = (i + "").substr((i + "").indexOf(".") + 1);
        tempstr = parseFloat(tempstr);
        if (tempstr >= 0.5) {
          tempstr = "30";
        } else {
          tempstr = "";
        }
      }
      hourline = "<ul class='hourline_ul'>";
      idx = 0;
      if (i === 0) {
        i = 1;
        cl = "li_24";
        hourline += " <li class='" + cl + "' id='lihr_0' idx='" + idx + "' t='0' ><div class='span_hl' idx='" + idx + "'><span idx='" + idx + "' class='small' >" + timearr[1] + "</span><br><span idx='" + idx + "' class='small' >" + timearr[2] + "</span></div></li>";
        idx++;
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
        hourline += " <li class='" + cl + "' id='lihr_" + i + "' idx='" + idx + "' t='" + i + "' ><div class='span_hl' idx='" + idx + "'><span class='medium' idx='" + idx + "'>" + parseInt(i) + "</span><br><span class='small' idx='" + idx + "'>" + tempstr + "</span></div></li>";
        if (tempstr === "") {
          hourline = hourline.replace("<span class='medium' idx='" + idx + "'>", "<span idx='" + idx + "' >");
        }
        idx++;
        i++;
      }
      if (hourstart !== 0) {
        monInNum = getMonth(timearr[1], {
          "type": "num"
        });
        d = new Date();
        d.setFullYear(timearr[3], monInNum, timearr[2]);
        d.setTime(d.getTime() + 86400000);
        d = d.toLocaleString();
        nextdayarr = d.split(" ");
        cl = "li_24";
        hourline += " <li class='" + cl + "' id='lihr_0' idx='" + idx + "' t='0'><div class='span_hl' idx='" + idx + "'><span idx='" + idx + "'  class='small'> " + nextdayarr[1] + "</span><br><span idx='" + idx + "' class='small' >" + nextdayarr[2] + "</span></div></li>";
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
        hourline += " <li class='" + cl + "' id='lihr_" + i + "' idx='" + idx + "' t='" + i + "'><div class='span_hl' idx='" + idx + "'><span class='medium' idx='" + idx + "'>" + parseInt(i) + "</span><br><span class='small' idx='" + idx + "'>" + tempstr + "</span></div></li>";
        if (tempstr === "") {
          hourline = hourline.replace("<span class='medium' idx='" + idx + "'>", "<span idx='" + idx + "' >");
        }
        i++;
        idx++;
      }
      hourline += "</ul>";
      row += "<div class='row' id='row_" + ind + "' rowindex='" + ind + "' time='" + timearr[4] + "' ><div class='tzdetails'><div class='offset'>" + (floatOffset - defaultoffset) + "</div><div class='location'><span class='city'>" + oldobj[ind].city + "</span><br><span class='country'>" + oldobj[ind].country + "</span></div><div class='timedata'><span class='time'>" + timearr[4] + "</span><br><span class='timeextra'>" + timearr[0] + " , " + timearr[1] + " " + timearr[2] + " " + timearr[3] + "</span></div></div><div class='dates'>" + hourline + "</div></div> ";
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
    console.log("left : " + left);
    left = left * 28;
    console.log(left + " : " + height);
    $("#selectedband").css("height", height);
    $("#selectedband").css("left", left);
    left = parseInt($("#selectedband").css("left"));
    $("#vband").css("left", left - 2);
    return $("#vband").css("height", $("#selectedband").css("height"));
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
    month[0] = "January";
    month[1] = "February";
    month[2] = "March";
    month[3] = "April";
    month[4] = "May";
    month[5] = "June";
    month[6] = "July";
    month[7] = "August";
    month[8] = "September";
    month[9] = "October";
    month[10] = "November";
    month[11] = "December";
    if (options.type === "num") {
      for (m in month) {
        if (month[m] === mon) return m;
      }
    } else if (options.type === "str") {
      return month[mon];
    }
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
