-- Find the total number of travelers
SELECT COUNT(*) as totol_num_of_traveller
FROM airline_passenger_satisfaction;

-- Find male and female status
SELECT
    COUNT(ID) AS number_of_travelers,
    Gender
FROM airline_passenger_satisfaction
GROUP BY Gender;

-- Find the number of personal or business visits
SELECT
    COUNT(ID) AS number_of_travelers,
    Type_of_Travel
FROM airline_passenger_satisfaction
GROUP BY Type_of_Travel;

-- Find class of traveler (economy and business)
SELECT
    COUNT(ID),
    Class
FROM airline_passenger_satisfaction
GROUP BY Class;

-- Satisfaction based on class of traveler
SELECT 
    Satisfaction,
    COUNT(*) AS in_number,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS in_percent
FROM airline_passenger_satisfaction
GROUP BY Satisfaction;

-- Number and percent of satisfied customers based on class
SELECT 
    Class,
    Satisfaction,
    COUNT(ID) AS number_of_travelers,
    ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (PARTITION BY Class), 2) AS percentage
FROM airline_passenger_satisfaction
GROUP BY Class, Satisfaction
ORDER BY Class, Satisfaction;

-- Number and percent of satisfied customers based on gender
SELECT 
    Gender,
    Satisfaction,
    COUNT(ID) AS number_of_travelers,
    ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (PARTITION BY Gender), 2) AS percentage
FROM airline_passenger_satisfaction
GROUP BY Gender, Satisfaction;

-- Categorize departure delays
WITH delayDetails AS (
    SELECT 
        CASE
            WHEN Departure_Delay > 10 THEN 'depart_delay'
            WHEN Departure_Delay = 0 THEN 'depart_on_time'
            ELSE 'depart_slight_delay'
        END AS depart_timing
    FROM airline_passenger_satisfaction
)
SELECT 
    depart_timing,
    COUNT(*) 
FROM delayDetails
GROUP BY depart_timing;

-- Categorize arrival delays (delayed or on time)
SELECT 
    CASE
        WHEN Arrival_Delay > 0 THEN 'delayed'
        ELSE 'on_time'
    END AS delay_status,
    COUNT(*) AS number_in_total,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS per
FROM airline_passenger_satisfaction
GROUP BY
    CASE
        WHEN Arrival_Delay > 0 THEN 'delayed'
        ELSE 'on_time'
    END;



-- Average delay time for both departure and arrival
SELECT 
    COUNT(*) AS total,
    AVG(Departure_Delay) AS average_departure_delay_time,
    AVG(Arrival_Delay) AS average_arrival_delay
FROM airline_passenger_satisfaction;

-- Percentage of customer types
SELECT 
    COUNT(*),
    Customer_Type,
    ROUND(100 * COUNT(ID) / SUM(COUNT(ID)) OVER (), 2) AS percentage
FROM airline_passenger_satisfaction
GROUP BY Customer_Type;


-- Create temporary table for average ratings
CREATE TABLE #average_rrra (
    ID INT,
    average_rating DECIMAL(5,2)
);

-- Insert data into temporary table
INSERT INTO #average_rrra (
    ID,
    average_rating
)
SELECT 
    ID,
    (Departure_and_Arrival_Time_Convenience + Ease_of_Online_Booking + Check_in_Service +
    Online_Boarding + Gate_Location + On_board_Service + Seat_Comfort +
    Leg_Room_Service + Cleanliness + Food_and_Drink + In_flight_Service + 
    In_flight_Wifi_Service + In_flight_Entertainment + Baggage_Handling) / 14.0 AS average_rating
FROM airline_passenger_satisfaction;

-- Average rating across all travelers
SELECT 
    ROUND(SUM(a.average_rating) / COUNT(a.ID), 2) AS average_rating
FROM airline_passenger_satisfaction b
JOIN #average_rrra a ON b.ID = a.ID;

-- Average rating based on class of the flight
SELECT 
    b.class,
    ROUND(SUM(a.average_rating) / COUNT(a.ID), 2) AS average_rating_based_on_class
FROM airline_passenger_satisfaction b
JOIN #average_rrra a ON b.ID = a.ID
GROUP BY b.class;

-- Ranting of 25% of the travelers with the least distance
WITH PercentRanked AS (
    SELECT 
        a.average_rating,
        b.Flight_Distance,
        PERCENT_RANK() OVER (ORDER BY b.Flight_Distance ASC) AS PercentRank
    FROM airline_passenger_satisfaction AS b
    JOIN #average_rrra AS a ON a.ID = b.ID
)
SELECT 
    SUM(average_rating) / COUNT(flight_distance)
FROM 
    PercentRanked
WHERE 
    PercentRank <= 0.25;

-- Rating of 25% of the travelers with more distance
WITH PercentRanked AS (
    SELECT 
        a.average_rating,
        b.Flight_Distance,
        PERCENT_RANK() OVER (ORDER BY b.Flight_Distance ASC) AS PercentRank
    FROM airline_passenger_satisfaction AS b
    JOIN #average_rrra AS a ON a.ID = b.ID
)
SELECT 
    SUM(average_rating) / COUNT(flight_distance)
FROM 
    PercentRanked
WHERE 
    PercentRank <= 0.75;

-- Good and bad service among the given categories for all 12 categorize
SELECT 'avg_departure_and_arrival_time_convenience' AS column_name, 
       AVG(CAST(Departure_and_Arrival_Time_Convenience AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_ease_of_online_booking' AS column_name, 
       AVG(CAST(Ease_of_Online_Booking AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_check_in_service' AS column_name, 
       AVG(CAST(Check_in_Service AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_online_boarding' AS column_name, 
       AVG(CAST(Online_Boarding AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_gate_location' AS column_name, 
       AVG(CAST(Gate_Location AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_on_board_service' AS column_name, 
       AVG(CAST(On_board_Service AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_seat_comfort' AS column_name, 
       AVG(CAST(Seat_Comfort AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_leg_room_service' AS column_name, 
       AVG(CAST(Leg_Room_Service AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_cleanliness' AS column_name, 
       AVG(CAST(Cleanliness AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_food_and_drink' AS column_name, 
       AVG(CAST(Food_and_Drink AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_in_flight_service' AS column_name, 
       AVG(CAST(In_flight_Service AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_in_flight_wifi_service' AS column_name, 
       AVG(CAST(In_flight_Wifi_Service AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_in_flight_entertainment' AS column_name, 
       AVG(CAST(In_flight_Entertainment AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
UNION ALL
SELECT 'avg_baggage_handling' AS column_name, 
       AVG(CAST(Baggage_Handling AS DECIMAL(5, 2))) AS value
FROM airline_passenger_satisfaction
ORDER BY value;
