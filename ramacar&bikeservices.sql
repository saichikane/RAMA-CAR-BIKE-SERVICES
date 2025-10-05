
use rama_cars;
select* from  bookings;
select*from bookings24;

# 1) join both datatable because we have same data in both table & save it  
     select * FROM bookings UNION ALL SELECT * FROM bookings24;
     #want to save as a table 
     create table ramacarandbikeservices as select * FROM bookings UNION ALL SELECT * FROM bookings24;
	 select * from ramacarandbikeservices ;
     
     select count(*) ramacarandbikeservices ;
     
# 2 ) clean dataset & change their datatype in proper format 

     # we need to change Date & Time column name because they allready default in Mysql 
     alter table ramacarandbikeservices 
     change Date Dates varchar(45);
     alter table ramacarandbikeservices
     rename column Time to Times ;
     
     #firstly check how much null value present in per columns
     create view Total_Null_Value as select
            sum(Dates is null ) as Dates_Null ,
            sum(Times is null ) as Times_Null ,
            sum(Booking_ID is null ) as  Booking_Null ,
            sum(Booking_Status is null ) as Bookingsatus_Null,
            sum(Customer_ID is null ) as Customer_ID_Null , 
            sum(Vehicle_Type is null ) as Vechicletype_Null ,
            sum(Pickup_Location is null ) as Pickuplocation_Null ,
            sum(Drop_Location is null ) as Droploaction_Null ,
            sum(V_TAT is null ) as V_TAT_Null ,
            sum(C_TAT IS null ) as C_TAT_NULL , 
            sum(Canceled_Rides_by_Customer is null ) as Canceled_Rides_by_Customer_Null ,
            sum(Incomplete_Rides is null ) as  Incomplete_Rides_Null , 
            sum(Incomplete_Rides_Reason  is null ) as  Incomplete_Rides_Reason_Null ,
            sum(Booking_Value is null ) as Bookingvalue_Null , 
            sum(Payment_Method is null ) as Payementmethod_Null , 
            sum(Ride_Distance is null ) as Ridedistance_Null ,
            sum(Driver_Ratings is null ) as driver_rating_Null ,
            sum(Customer_Rating is null ) as Customerrating_Null 
     from ramacarandbikeservices;
     
     select * from Total_Null_Value ; #total null value per columns 
            
     #Before dealing with null value drop unnessary columns or add new columns as per business requirement (vechcle images) 
     alter table ramacarandbikeservices drop column `Vehicle Images` ; #spce was there that why `` this used 
     
     #Temporarily disable Safe Update Mode
     SET SQL_SAFE_UPDATES = 0;
     
     #replace all  null value or deal with them 
     update ramacarandbikeservices
     set 
     V_TAT = ifnull(V_TAT , 0),
     C_TAT = ifnull(C_TAT , 0),
     Canceled_Rides_by_Customer = ifnull(Canceled_Rides_by_Customer ,"Don,t know"),
     Canceled_Rides_by_Driver = ifnull(Canceled_Rides_by_Driver , "Don,t know"),
     Incomplete_Rides = ifnull(Incomplete_Rides , "Don,t know"),
     Incomplete_Rides_Reason = ifnull(Incomplete_Rides_Reason , "Don,t know"),
     Payment_Method = ifnull(Payment_Method , "Don,t know"),
     Driver_Ratings = ifnull(Driver_Ratings , 00),
     Customer_Rating = ifnull(Customer_Rating , 00)
     where
          V_TAT IS NULL OR C_TAT IS NULL OR Canceled_Rides_by_Customer IS null OR Canceled_Rides_by_Driver IS NULL OR 
          Incomplete_Rides IS NULL OR Incomplete_Rides_Reason IS NULL OR Payment_Method IS NULL OR Driver_Ratings IS NULL 
          OR Customer_Rating IS NULL ;
          
    #check datatype of each columns & change according
    
    #check datatype and length size of columns
    SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ramacarandbikeservices'
    AND TABLE_SCHEMA = 'rama_cars';
    
    select * FROM ramacarandbikeservices ;
    
    #convert datatypes
    Alter table ramacarandbikeservices
    Modify column Dates datetime ,
    modify column Times time ,
    modify column Booking_ID varchar(45),
    modify column Booking_Status varchar(45),
    modify column Customer_ID varchar(45),
    modify column Vehicle_Type text ,
    modify column Pickup_Location text ,
    modify column Drop_Location text , 
    modify column Canceled_Rides_by_Customer text , 
    modify column Canceled_Rides_by_Driver text , 
    modify column Incomplete_Rides_Reason text ,
    modify column Incomplete_Rides text ,
    modify column Booking_Value int ,
    modify column Payment_Method text ,
    modify column Ride_Distance int ,
    modify column Driver_Ratings boolean ,
    modify column Customer_Rating boolean ,
    modify column V_TAT int ,
    modify column C_TAT int ;

# 3 ) Reduce cost and unessary expense

     #check datatable first 
     select * from ramacarandbikeservices;
     # finding vechicle which not like by costumer (group by with condition)
     
     #01 ( Most cancelled ride by costumers )
     create view cacelled_ride_per_vechicles as 
     select Vehicle_Type , Booking_Status , count(*) as cacelled_ride_per_vechicle
     from ramacarandbikeservices 
     where Booking_Status = 'Canceled by Customer'
     group by Vehicle_Type , Booking_Status ;
     select * from cacelled_ride_per_vechicles ;
     
     #02 (ride which have less than mean(avg) costumer ratings)
     
     #finding AVG of costumer rating but its not work in mysql its work in pandas 
     create view Avg_Customer_Ratings as select avg(Customer_Rating) from ramacarandbikeservices ;
     
     #group by with which vechicle has less than avg customer ratings
     create view No_Of_Vechiclehave_lessthan_avgCRn as select Vehicle_Type, Customer_Rating, count(*) as
     Noofride_withlessthanavgratings from ramacarandbikeservices r  
     where Customer_Rating <=( select avg(Customer_Rating) from ramacarandbikeservices where Vehicle_Type = r.Vehicle_Type)
     group by Vehicle_Type, Customer_Rating;
     
     select * from No_Of_Vechiclehave_lessthan_avgCRn ;
     
     
# 4 ) Thinking about reduce some vechicle

     select * from No_Of_Vechiclehave_lessthan_avgCR ; #Vechicle which have less than avg costomer ratings
     select * from cacelled_ride_per_vechicles ;       #Vechicle which have less than avg costomer ratings 
     
# 5 ) WAnt to know which time and day we get maximun order
      #firstly extract for time (hour) 
      #secondaly extract for day 
      
# 6 ) identify fake bookings

      #identify wise customer_id who canceled most ride 
      create view Customerwho_cancelledmost_ride AS select Customer_ID , Booking_Status , count(*) as 
      customer_Wcancelled_mostrides from ramacarandbikeservices where Booking_Status = 'Canceled by Customer'
      group by Customer_ID , Booking_Status limit 10 ;
      select * from Customerwho_cancelledmost_ride ; 
      
      #identify wise area which area have maximum cancled rides
      select * from Most_Canclledorder_Area;
      
# 7 ) High Ride cancellation rate area

      create view Most_Canclledorder_Area as select Drop_Location , Booking_Status , count(*) as most_cancledorder_area
      from ramacarandbikeservices where Booking_Status = 'Canceled by Customer' 
      group by Drop_Location , Booking_Status limit 10 ;
      select * from Most_Canclledorder_Area;
      
# 8 ) Thinking to open new office so where should open

      #which area give us maximun ride order also for which area 
      #form which area we getting maximun ride 
      create view Most_ride_weget_bylocation as select Vehicle_Type , Pickup_Location , Booking_Status , count(*) as
      Totalride_weget_bylocation from ramacarandbikeservices where Booking_Status =  'Success'
      group by Vehicle_Type , Pickup_Location , Booking_Status limit 10 ; 
      select * from Most_ride_weget_bylocation ;
      #for which area we get maximun rides 
	  create view Forwhich_loc_getmax_rides as select Vehicle_Type , Drop_Location , Booking_Status , count(*) as
      forwhichareawegetmaximun_rides from ramacarandbikeservices where Booking_Status = 'Success'
      group by Vehicle_Type , Drop_Location , Booking_Status limit 10 ;
      select * from Forwhich_loc_getmax_rides ;
      
# 9 ) Want to reward loyal costumer

      create view Looyal_Customer as select Customer_ID , Booking_Status , 
      count(*) as loyalcustomer from ramacarandbikeservices where Booking_Status = 'Success' 
      group by Customer_ID , Booking_Status limit 10 ;
      select * from Looyal_Customer;
      
# 10 ) Driver behaviour towords costumer 

      select * from No_Of_Vechiclehave_lessthan_avgCR ; #Vechicle which have less than avg costomer ratings
      select * from cacelled_ride_per_vechicles ;       #Vechicle which have less than avg costomer ratings 
      
# 11 ) Want to know in which location people like which vechicle type for all location

      create view Mostlike_V_BY_AREA AS select Vehicle_Type , Drop_Location , count(*) as vehiclelikenumbers
      from ramacarandbikeservices group by Vehicle_Type , Drop_Location ;
      select * from Mostlike_V_BY_AREA ;
