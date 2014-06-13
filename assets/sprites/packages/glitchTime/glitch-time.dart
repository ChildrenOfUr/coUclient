library glitchTime;

List Months = 
    [
     'Primuary',
     'Spork',
     'Bruise',
     'Candy',
     'Fever',
     'Junuary',
     'Septa',
     'Remember',
     'Doom',
     'Widdershins',
     'Eleventy',
     'Recurse'
     ];
List Days_of_Week =
     [
      'Hairday',
      'Moonday',
      'Twoday',
      'Weddingday',
      'Theday',
      'Fryday',
      'Standday',
      'Fabday'     
     ];



floor(num me){
return me.floor();
}


//
// how many real seconds have elapsed since game epoch?
//
int ts = (new DateTime.now().millisecondsSinceEpoch*0.001).floor(); 

int sec = ts - 1238562000;


List getDate(){
//
// there are 4435200 real seconds in a game year
// there are 14400 real seconds in a game day
// there are 600 real seconds in a game hour
// there are 10 real seconds in a game minute
//
int ts = (new DateTime.now().millisecondsSinceEpoch*0.001).floor(); 
int sec = ts - 1238562000;

int year = floor(sec / 4435200);
sec -= year * 4435200;

int day_of_year = floor(sec / 14400);
sec -= day_of_year * 14400;

int hour = floor(sec / 600);
sec -= hour * 600;

int minute = floor(sec / 10);
sec -= minute * 10;


//
// turn the 0-based day-of-year into a day & month
//

List MonthAndDay = day_to_md(day_of_year);


//
// get day-of-week
//

int days_since_epoch = day_of_year + (307 * year);

int day_of_week = days_since_epoch % 8;



//
// Append to our day_of_month
//
String suffix;
if (MonthAndDay[1].toString().endsWith('1'))
  suffix = 'st';
else if (MonthAndDay[1].toString().endsWith('2'))
  suffix = 'nd';
else if (MonthAndDay[1].toString().endsWith('3'))
  suffix = 'rd';
else
  suffix = 'th';

//
// Fix am pm times
//

String h = (hour).toString();
String m = minute.toString();
String ampm = 'am';
if (minute<10)
       m = '0'+minute.toString();
if (hour >= 12){
  ampm = 'pm';
  if (hour > 12)
  h = (hour-12).toString();
}
if (h == '0')
h = (12).toString();
String CurrentTime = (h + ':' + m + ampm);



return ['Year '+year.toString(),Months[MonthAndDay[0]-1],MonthAndDay[1].toString() + suffix,Days_of_Week[day_of_week],CurrentTime];
}


List day_to_md(id){

  List months = [29, 3, 53, 17, 73, 19, 13, 37, 5, 47, 11, 1];
  int cd = 0;

  int daysinMonths = months[0]+
                     months[1]+
                     months[2]+
                     months[3]+
                     months[4]+
                     months[5]+
                     months[6]+
                     months[7]+
                     months[8]+
                     months[9]+
                     months[10]+
                     months[11];
  
  for (int i=0; i<(daysinMonths); i++){
    cd += months[i];
    if (cd > id){
      int m = i+1;
      int d = id+1 - (cd - months[i]);
      return [m, d];
    }
  }

  return [0, 0];
}