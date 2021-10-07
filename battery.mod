set PRODUCT;
set RESOURCE;
set SCENARIO;
set SCENARIO_1;
set PERIOD0_TO_END;
set PERIOD1_TO_END;
set PERIOD2_TO_END;
set ONLY0;
set ONLY1;
set TECHNOLOGY;
set DAY_IN_PERIOD;
set DAYS_IN_PERIOD1;
set DAYS_IN_PERIOD2;
set DAY0;
set FIRST_DAY;
set OTHER_DAYS;



param I >0;
param R >0;
param S >0;
param T >0;
param C >0;
param G >0;
param J >0;


param Purchase_cost {PRODUCT,PERIOD1_TO_END} >= 0;
param Prodcost{PRODUCT, PERIOD1_TO_END} >= 0; 
param Demand{PRODUCT,PERIOD1_TO_END,SCENARIO} >= 0; 
param holding_cost{PRODUCT, PERIOD1_TO_END} >= 0;
param prob{SCENARIO}>=0;
param Inv0prod{PRODUCT}>= 0;
param Resource{PRODUCT,RESOURCE} >0;
param avail{RESOURCE, PERIOD1_TO_END} >0;
#param MPC{PERIOD1_TO_END} ;
#param MP{PERIOD1_TO_END} ;
#param MS{PERIOD1_TO_END} ;
param scen_links{SCENARIO, SCENARIO_1};
param scen_links1{SCENARIO, SCENARIO_1};


param transcost{PRODUCT, PERIOD1_TO_END} >=0;
param phi_tech{TECHNOLOGY} >=0;
param phi_battery >=0;
param acost_tech{TECHNOLOGY} >=0;
param acost_battery>=0;
param annual_om_cost{TECHNOLOGY} >=0;
param annual_penalty_cost{TECHNOLOGY} >=0;
param energy_consumed{PRODUCT} >=0;
param energy_intensity_rate >=0;
param distance >=0;
param unit_weight{PRODUCT} >=0;
param number_trips >=0;
param self_weight >=0;
param generation_hours{TECHNOLOGY} >=0;
param generation_hours_year >=0;
param days_operational_hours >=0;
param electricity_demand_fac{SCENARIO}>=0;
param electricity_demand_war{SCENARIO}>=0;
param product_demand{PRODUCT} >=0;
param cap_factor{TECHNOLOGY,DAY_IN_PERIOD,SCENARIO};
param cap_factor1{TECHNOLOGY,1..31};
param max_battery;
param max_tech{TECHNOLOGY};
param month1{DAYS_IN_PERIOD1}>=0;
param month2{DAYS_IN_PERIOD2}>=0;
param Battery_facility1{DAY0} >= 0 ;

param days_in_period1 >=0;
param days_in_period2 >=0;
param days_in_period12 >=0;

var Produce{PRODUCT,ONLY1} >= 0; 
var Produce2{PRODUCT,PERIOD2_TO_END,SCENARIO} >= 0;
var Inventory{PRODUCT,ONLY0} >= 0;  
var Inventory2{PRODUCT,PERIOD1_TO_END, SCENARIO} >= 0;
var Product_purchased{PRODUCT,PERIOD1_TO_END,SCENARIO} >= 0;
var Tech_capacity{TECHNOLOGY} >=0; 
var Battery_facility2{DAY_IN_PERIOD, SCENARIO} >= 0;
var Batt_capacity1 >= 0;


minimize Total_cost: sum{i in PRODUCT} (Prodcost[i,1]+transcost[i,1]) * Produce[i,1] + sum {i in PRODUCT,s in SCENARIO} prob[s]*holding_cost[i,1]*Inventory2[i,1,s] + sum {i in PRODUCT,s in SCENARIO} prob[s]*Purchase_cost[i,1]*Product_purchased[i,1,s]
+ sum{i in PRODUCT,t in PERIOD2_TO_END,s in SCENARIO} prob[s]*((Prodcost[i,t]+transcost[i,t])*Produce2[i,t,s]+Purchase_cost[i,t]*Product_purchased[i,t,s]+holding_cost[i,t]*Inventory2[i,t,s]) + sum{g in TECHNOLOGY} phi_tech[g]*acost_tech[g]*Tech_capacity[g] 
+ sum{g in TECHNOLOGY,s in SCENARIO} prob[s]*(annual_om_cost[g] - annual_penalty_cost[g])*generation_hours_year*(sum{j in DAY_IN_PERIOD}(cap_factor[g,j,s]/days_in_period12))*Tech_capacity[g];

subject to
Init_inv1{i in PRODUCT}: Inventory[i,0] = Inv0prod[i];

       
#without purchasing                                             
Balance{s in SCENARIO,t in ONLY1,i in PRODUCT}: Produce[i,t] + Inventory[i,t-1] = Demand[i,t,s] + Inventory2[i,t,s];                                               
Balance2{s in SCENARIO,t in PERIOD2_TO_END,i in PRODUCT}: Produce2[i,t,s] + Inventory2[i,t-1,s] = Demand[i,t,s] + Inventory2[i,t,s];  
                                                                                    
                                             
Resource_req{r in RESOURCE,t in ONLY1}: sum {i in PRODUCT} Resource[i,r]*Produce[i,t] <= avail[r,t];
Resource_req2{s in SCENARIO,r in RESOURCE,t in PERIOD2_TO_END}: sum {i in PRODUCT} Resource[i,r]*Produce2[i,t,s] <= avail[r,t];
Nonanticip1{c in SCENARIO_1,i in PRODUCT,t in PERIOD2_TO_END}:(sum{s in SCENARIO} scen_links1[c,s]*prob[s]*Produce2[i,t,s])-(sum{s in SCENARIO}scen_links1[c,s]*prob[s]*Produce2[i,t,c]) = 0;

#Energy constraints
#This is for the first day of the first month
Facility_demand1{t in ONLY1, j in FIRST_DAY,s in SCENARIO}: sum{i in PRODUCT} ((energy_consumed[i] + energy_intensity_rate*distance*unit_weight[i])*(Produce[i,t]/days_in_period1)) + sum{i in PRODUCT} (product_demand[i]*(Inventory2[i,t,s]/days_in_period1)) + days_operational_hours*electricity_demand_fac[s] + energy_intensity_rate*number_trips*distance*self_weight = sum {g in TECHNOLOGY} generation_hours[g]*Tech_capacity[g]*cap_factor[g,j,s];

#This is for the remaining days in January
Facility_demand12{t in ONLY1, j in 2..31,s in SCENARIO}: sum{i in PRODUCT} ((energy_consumed[i] + energy_intensity_rate*distance*unit_weight[i])*(Produce[i,t]/days_in_period1)) + sum{i in PRODUCT} (product_demand[i]*(Inventory2[i,t,s]/month1[j])) + days_operational_hours*electricity_demand_fac[s] + energy_intensity_rate*number_trips*distance*self_weight = sum {g in TECHNOLOGY} generation_hours[g]*Tech_capacity[g]*cap_factor[g,j,s];

# This is for all the days in all the next months
Facility_demand2{t in PERIOD2_TO_END,j in DAYS_IN_PERIOD2,s in SCENARIO}: (sum{i in PRODUCT} (energy_consumed[i] + energy_intensity_rate*distance*unit_weight[i])*(Produce2[i,t,s]/days_in_period2)) + sum{i in PRODUCT} (product_demand[i]*(Inventory2[i,t,s]/month2[j])) + days_operational_hours*electricity_demand_fac[s] + energy_intensity_rate*number_trips*distance*self_weight
= sum {g in TECHNOLOGY} generation_hours[g]*Tech_capacity[g]*cap_factor[g,j,s];


Max_tech_facility{g in TECHNOLOGY}: Tech_capacity[g]<= max_tech[g];



