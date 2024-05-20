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
    - figure out what format is required
4. Query API for schedule
    - https://data.sfgov.org/City-Infrastructure/Street-Sweeping-Schedule/yhqp-riqs/about_data
    - can either query API each time or:
        - create my own database (dynamoDB/AWS Amplify)
        - database queries changes from sfgov daily/weekly
        - app will make api requests to my own AWS backend
4. Display street sweeping schedule
5. Push notifications