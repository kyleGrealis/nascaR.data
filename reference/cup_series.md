# NASCAR Cup Series Race Data

Historical race results for NASCAR Cup Series races from 1949-present.
Includes finishing position, driver and car information, track details,
and performance metrics for each entry.

## Usage

``` r
cup_series
```

## Format

A data frame with rows representing each car/driver entry and 19
columns:

- Season:

  Race season year

- Race:

  Race number within the season

- Track:

  Name of the racetrack

- Name:

  Official race name

- Length:

  Track length in miles

- Surface:

  Track surface type (e.g., "road", "oval")

- Finish:

  Finishing position

- Start:

  Starting position

- Car:

  Car number

- Driver:

  Driver name

- Team:

  Racing team name

- Make:

  Car manufacturer

- Pts:

  Championship points earned

- Laps:

  Number of laps completed

- Led:

  Number of laps led

- Status:

  Race completion status (e.g., "running", "crash")

- S1:

  Segment 1 finish position

- S2:

  Segment 2 finish position

- Seg Points:

  Segment points – deprecated

- Rating:

  Driver rating for the race

- Win:

  Binary indicator if driver won the race (1 = yes, 0 = no)

## Source

Data scraped from Driver Averages (https://www.driveraverages.com)
