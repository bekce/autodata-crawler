# autodata-crawler
Content (car data and images) crawler for http://auto-data.net

Can crawl car data and car images. Saves car data to structured xml files, so that it can be read later preferably to a database. Car images are saved into respective folders for each type of car.

It uses [`xidel`](http://www.videlibri.de/xidel.html) to do the xml parsing with respect to XPATH. The executable is included with the repository.

Code was written in 2013, but I have recently (2015-10-26) tested it and it is running.

## How to run

### Car data crawler
```
./cardata_starter.sh 
Usage: <from> (inclusive) <to> (exclusive) <per_process>
Example: 0 19000 100
```
Output folder: `./cardata`

Numbers are taken from urls of the car data, such as `http://www.auto-data.net/tr/?f=showCar&car_id=xxxxx`. `cardata_starter.sh` creates multiple `cardata.sh` processes. The example (0 19000 100) creates 190 processes which handle 100 cars each.

### Car images crawler
```
./images.sh 
Usage: <from> (inclusive) <to> (exclusive)
Example: ./images.sh 1 10667 2>/dev/null 
```
Output folder: `./images`

## Limitations (please contribute!)

- It uses Turkish site (http://www.auto-data.net/tr/) so the data comes in Turkish. You can change the language parameter to your liking (even better, improve it to accept the language as a parameter and send a pull request!). You should probably change `images.sh:47` to correctly parse the car name.
