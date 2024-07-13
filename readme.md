# ParkSF #

Hi, I built this app in order to help with parking in San Francisco.


# Outline #

1. Get user location
    - latitude/longitude coordinates
2. Determine when user is parked
    - look at velocity/acceleration? carplay integration/bluetooth?
    - need to figure out which side of street user is on
    - reverse geocode into street address
    - allow user to manually set parked address
3. Translate street address into format that can be searched up
    - https://data.sfgov.org/Geographic-Locations-and-Boundaries/List-of-Streets-and-Intersections/pu5n-qu5c/about_data
    - placemark.thoroughfare -> streetname
    - placemark.subThoroughfare -> addrrange
    - return unique centerline network number CNN
    - lf_fadd and rt_fadd to determine street side is L or R
    - possible edge cases to check:
        - [x] streets with medians
        - [x] streets with range of address numbers (247-299 Divisadero St)
        - [ ] buildings on corners do not reverse geocode nicely-can end up on wrong street.
        - [ ] road name mismatch (22 Upper Terr vs 22 Upper Ter, buena vista ave w->buena vista ave west)
4. Search schedule for street address
    - https://data.sfgov.org/City-Infrastructure/Street-Sweeping-Schedule/yhqp-riqs/about_data
    - filter on CNN and CNNRightLeft
    - can either query API each time or:
        - create my own database (RDS/dynamoDB/AWS Amplify)
        - database queries changes from sfgov daily/weekly
        - app will make api requests to my own AWS backend
    - possible edge cases to check:
        - [ ] one way streets
        - [ ] is one side of the street always even/odd numbered or are parities mixed
        - [ ] some streets have multiple days/times
        - [ ] schedules differ for each week
4. Display street sweeping schedule
5. Push notifications

# TODO #

- create a controller - MVC framework
- implement push notifications
    - NotificationManager
    - NotificationView
- generate new app_token and store locally/encrypt
- a way to dump debug information? should save a log to aws?
- move database onto AWS, update API to point to AWS
- app icons
- git remove unecessary files?

# Settings

- 12/24 hr time
- notification time