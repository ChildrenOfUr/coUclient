part of couclient;

class CalendarWindow extends Modal {
  String id = 'calendarWindow';

  CalendarWindow() {
    prepare();

    // display current date and time //

    var daynum;

    new Service(['timeUpdate'], (event) {
      querySelector("#calCurrDay").text = clock.dayofweek;
      querySelector("#calCurrTime").text = clock.time;
      querySelector("#calCurrDate").text = clock.day + ' of ' + clock.month;

      // format day for today checking //
      String daynumtext = clock.day;
      daynumtext = daynumtext.substring(0, daynumtext.length - 2);
      daynum = int.parse(daynumtext);
      assert(daynum is int);
    });

    // get calendar data //

    String jsonQfetchQ = '''
{
  "months": {
    "Primuary": 29,
    "Spork": 3,
    "Bruise": 53,
    "Candy": 17,
    "Fever": 73,
    "Junuary": 19,
    "Septa": 13,
    "Remember": 37,
    "Doom": 5,
    "Widdershins": 47,
    "Eleventy": 11,
    "Recurse": 1
  },

  "start_day_skip": {
    "Primuary": 2,
    "Spork": 1,
    "Bruise": 4,
    "Candy": 3,
    "Fever": 2,
    "Junuary": 3,
    "Septa": 4,
    "Remember": 5,
    "Doom": 0,
    "Widdershins": 5,
    "Eleventy": 4,
    "Recurse": 3
  },

  "holidays": {
    "Primuary": {
      "5": "AlphaCon"
    },

    "Spork": {
      "2": "Lemadan"
    },

    "Bruise": {
      "3": "Pot Twoday"
    },

    "Candy": {
      "2": "Root",
      "3": "Root",
      "4": "Root",
      "11": "Sprinkling"
    },

    "Fever": {},

    "Junuary": {
      "17": "Croppaday"
    },

    "Septa": {
      "1": "Belabor Day"
    },

    "Remember": {
      "25": "Zilloween",
      "26": "Zilloween",
      "27": "Zilloween",
      "28": "Zilloween",
      "29": "Zilloween",
      "30": "Zilloween",
      "31": "Zilloween",
      "32": "Zilloween",
      "33": "Zilloween",
      "34": "Zilloween",
      "35": "Zilloween",
      "36": "Zilloween",
      "37": "Zilloween"
    },

    "Doom": {},

    "Widdershins": {},

    "Eleventy": {
      "11": "Recurse Eve"
    },

    "Recurse": {
      "1": "Recurse"
    }
  }
}
    ''';

    Map json = JSON.decode(jsonQfetchQ);
    Map months = json["months"];
    List monthNames = months.keys.toList();
    Map startMonthSkipBoth = json["start_day_skip"];
    List startMonthSkip = startMonthSkipBoth.values.toList();
    //Map holidays = json["holidays"];
    Element calendarview = querySelector("#calendar-view");

    // repeat for every month //
    for (int i = 0; i != months.length; i++) {
      String monthname = monthNames[i];
      int numDays = months.values.toList()[i];
      int skipDays = startMonthSkip[i];

      DivElement month = new DivElement()..classes = ['month'];
      month.append(new DivElement()..classes = ['month-name']..text = monthname);

      num numWeeksRaw = (numDays + skipDays) / 6;
      int numWeeks = numWeeksRaw.ceil();

      // repeat for each week //
      int weekLengthSF = 0;
      for (int l = 0; l != numWeeks; l++) {

        DivElement week = new DivElement()..classes = ['week'];

        if (weekLengthSF == 6) {
          // week is full, add it and start a new one //
          if (week.querySelectorAll(".day").length < 6) {
            int missingDays = 6 - week.querySelectorAll(".day").length;
            for (int m = 0; m != missingDays; m++) {
              week.append(new DivElement()..classes = ['day']);
            }
          }
          month.append(week);
          weekLengthSF = 0;
        } else {
          // skip days before month starts //
          for(int k = 0; k != skipDays; k++) {
            DivElement day = new DivElement()..classes = ['day'];
            week.append(day);
            month.append(week);
            weekLengthSF++;
          }

          // repeat for every day in given month //
          for (int j = 1; j != numDays + 1; j++) {
            DivElement day;

            if (j == daynum) {
              day = new DivElement()..classes = ['day', 'today'];
            } else {
              day = new DivElement()..classes = ['day'];
            }

            day.append(new DivElement()..text = j.toString());
            week.append(day);
            weekLengthSF++;
          }
        }
      }

      calendarview.append(month);
    }

    // launch //

    querySelector("#time").onClick.listen((_) {
      this.open();
    });
  }
}