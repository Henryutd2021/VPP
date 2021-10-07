
model;

#SET
set Gens:={"WT", "PV"};       #Set of renewable generation product types  
set ESS:={"BS", "SC"};       #Set of renewable generation product types  
set Factory:={"SanF"};
set Warehouse:={"LasV"};
set Store:={"Pho"};


param T;
#set steps ordered;                       #Set of time periods (t=8760) 
set periods:= 1..T by 1 ordered;
set steps:=0..T by 1 ordered; 
set LINK within {Factory, periods};
#PARAMETER
param Y;                              # 20 years investment  
param r;                              # interest rate
#param Q=(r*(1+r)^Y)/((1+r)^Y-1);      # 20 year(20,0.5)=0.0802 
param Q:=0.08024;

param CHP_eff;       #Electrical efficiency of CHP in the facilities (typically 30-40%).
param gas_price;     #Natural gas price (unit: $/MWh).
param CHP_EtoT_eff;  #Thermal to electric power ratio of CHP in the facilities (typical range is 2 to 10).



param CHP_E_F_max{f in Factory};        #Maximum electric power of CHP in factory (Unit: MW).
param CHP_E_F_min{f in Factory};        #Minmum electric power of CHP in factory (Unit: MW).

param CHP_E_W_max{w in Warehouse};      #Maximum electric power of CHP in Warehouse (Unit: MW).
param CHP_E_W_min{w in Warehouse};      #Minmum electric power of CHP in Warehouse (Unit: MW).

param CHP_E_S_max{s in Store};         #Maximum electric power of CHP in Store (Unit: MW).
param CHP_E_S_min{s in Store};         #Minmum electric power of CHP in Store (Unit: MW).


param CHP_T_F_max{f in Factory};       #Maximum THERMAL power of CHP in factory (Unit: MW).
param CHP_T_F_min{f in Factory};       #Minmum THERMAL power of CHP in factory (Unit: MW).

param CHP_T_W_max{w in Warehouse};    #Maximum THERMAL power of CHP in Warehouse (Unit: MW).
param CHP_T_W_min{w in Warehouse};    #Minmum THERMAL power of CHP in Warehouse (Unit: MW).

param CHP_T_S_max{s in Store};          #Maximum THERMAL of CHP in Store (Unit: MW).
param CHP_T_S_min{s in Store};          #Minmum THERMALof CHP in Store (Unit: MW).

param a1_G{n in Gens};             #capacity cost OF renewable generators
param a1_ESS;            #capacity cost OF renewable generators

param a2_G{n in Gens};             # O/M cost OF renewable generators
param a2_ESS;            # O/M cost OF renewable generators
param a2_CHP=gas_price/CHP_eff;    #Operating cost of CHP in factory. (unit: $/MWh).

param a3_G{n in Gens};             # carbon credit of each location and each 

param CF_F{t in periods,f in Factory,n in Gens};    #Capacity factor of renewable generator g in factory at time t.
param CF_W{t in periods,w in Warehouse,n in Gens};  #Capacity factor of renewable generator g in warehouse at time t.
param CF_S{t in periods,s in Store,n in Gens};      #Capacity factor of renewable generator g in store at time t.

param Price_DA_F{t in periods,f in Factory};        #Price of day-ahead energy traded by factory at time t (unit: $/MWh).
param Price_DA_W{t in periods,w in Warehouse};      #Price of day-ahead energy traded by Warehouse at time t (unit: $/MWh).
param Price_DA_S{t in periods,s in Store};          #Price of day-ahead energy traded by stores at time t (unit: $/MWh).

param D_E_F{t in periods,f in Factory};        #Electric power load of factory. (unit: MW)
param D_E_W{t in periods,w in Warehouse};
param D_E_S{t in periods,s in Store}; 

param D_T_F{t in periods,f in Factory};        #Thermal load of factory. (unit: MW)
param D_T_W{t in periods,w in Warehouse};
param D_T_S{t in periods,s in Store}; 

param ESS_E_F_min{f in Factory};        #Minmum capacity limit of ES  in factory (Unit: MW).
param ESS_E_W_min{w in Warehouse};      #Minmum capacity limit of ES  in Warehouse (Unit: MW).
param ESS_E_S_min{s in Store};          #Minmum Tcapacity limit of ES  in Store (Unit: MW).

param ESS_E_F_max{f in Factory};        #Minmum capacity limit of ES  in factory (Unit: MW).
param ESS_E_W_max{w in Warehouse};     #Minmum capacity limit of ES  in Warehouse (Unit: MW).
param ESS_E_S_max{s in Store}; 


param ESS_T_F_max{f in Factory};         #Maximum capacity of thermal storage in factory 
param ESS_T_F_min{f in Factory};         #Minmum capacity of thermal storage in factory

param ESS_T_W_max{w in Warehouse};       #Maximum capacity of thermal storage in Warehouse (Unit: MW).
param ESS_T_W_min{w in Warehouse};       #Minmum capacity of thermal storage  in Warehouse (Unit: MW).

param ESS_T_S_max{s in Store};           #Maximum capacity of thermal storage  in Store (Unit: MW).
param ESS_T_S_min{s in Store};           #Minmum capacity of thermal storage in Store (Unit: MW).

param CHP_trade_F{t in periods,f in Factory};     #Power output of electricity of CHP in factory at time t (unit: MW)
param CHP_trade_W{t in periods,w in Warehouse};   #Power output of electricity of CHP in warehouse at time t (unit: MW)
param CHP_trade_S{t in periods,s in Store};        #Power output of electricity of CHP in STORE at time t (unit: MW)

#Variable#

var G_F{g in Gens,f in Factory}>=0;      #Power capacity of renewable generator g in factory 
var G_W{g in Gens,w in Warehouse}>=0;   #Power capacity of renewable generator g in factory 
var G_S{g in Gens,s in Store}>=0;       #Power capacity of renewable generator g in factory 


var ESS_F{f in Factory}>=0;      #ESS capacity  in factory 
var ESS_W{w in Warehouse}>=0;   #PESS capacity  in warehouse
var ESS_S{s in Store}>=0;        #ESS capacity  in STORE

var ESS_E_F{t in steps,f in Factory}>=0;      #Electricity stored  in factory at t 
var ESS_E_W{t in steps,w in Warehouse}>=0;   #Electricity  stored   in warehouse at t
var ESS_E_S{t in steps,s in Store}>=0;        #Electricity  stored   in STORE at t

var ESS_T_F{t in steps,f in Factory}>=0;     #Thermal stored  in factory at t 
var ESS_T_W{t in steps,w in Warehouse}>=0;   #Thermal  stored   in warehouse at t
var ESS_T_S{t in steps,s in Store}>=0;        #Thermal stored   in STORE at t


var CHP_E_F{t in periods,f in Factory}>=0;      #Power output of electricity of CHP in factory at time t (unit: MW)
var CHP_E_W{t in periods,w in Warehouse}>=0;   #Power output of electricity of CHP in warehouse at time t (unit: MW)
var CHP_E_S{t in periods,s in Store}>=0;        #Power output of electricity of CHP in STORE at time t (unit: MW)

var CHP_T_F{t in periods,f in Factory}>=0;      #Thermal output of electricity of CHP in factory at time t (unit: MW)
var CHP_T_W{t in periods,w in Warehouse}>=0;   #Thermaloutput of electricity of CHP in warehouse at time t (unit: MW)
var CHP_T_S{t in periods,s in Store}>=0;        #Thermal output of electricity of CHP in STORE at time t (unit: MW)




#Capacity cost
var cap_cost_Gens=sum{n in Gens,f in Factory}Q*a1_G[n]*G_F[n,f]
                  +sum{n in Gens,w in Warehouse}Q*a1_G[n]*G_W[n,w]
                  +sum{n in Gens,s in Store}Q*a1_G[n]*G_S[n,s];

var cap_cost_ESS=sum{f in Factory}0.12*a1_ESS*ESS_F[f]
                  +sum{w in Warehouse}0.12*a1_ESS*ESS_W[w]
                  +sum{s in Store}0.12*a1_ESS*ESS_S[s];
 
                                     
# Maintance cost for battery only consider charging process
 var OM_cost_G = sum{t in 1..T,f in Factory}(a2_G["WT"]*G_F["WT",f]*CF_F[t,f,"WT"]+a2_G["PV"]*G_F["PV",f]*CF_F[t,f,"PV"])
               +sum{t in 1..T,w in Warehouse}(a2_G["WT"]*G_W["WT",w]*CF_W[t,w,"WT"]+a2_G["PV"]*G_W["PV",w]*CF_W[t,w,"PV"])
               +sum{t in 1..T,s in Store}(a2_G["WT"]*G_S["WT",s]*CF_S[t,s,"WT"]+a2_G["PV"]*G_S["PV",s]*CF_S[t,s,"PV"]) ;                


var OM_cost_ESS = sum{f in Factory}a2_ESS*ESS_F[f]
                  +sum{w in Warehouse}a2_ESS*ESS_W[w]
                  +sum{s in Store}a2_ESS*ESS_S[s];


var OM_cost_CHP = sum{f in Factory,t in 1..T}CHP_E_F[t,f]*a2_CHP
                 +sum{w in Warehouse,t in 1..T}CHP_E_W[t,w]*a2_CHP
                 +sum{s in Store,t in 1..T}CHP_E_S[t,s]*a2_CHP;


#Carbon credit
var CC_income = sum{t in 1..T,f in Factory}(a3_G["WT"]*G_F["WT",f]*CF_F[t,f,"WT"]+a3_G["PV"]*G_F["PV",f]*CF_F[t,f,"PV"])
               +sum{t in 1..T,w in Warehouse}(a3_G["WT"]*G_W["WT",w]*CF_W[t,w,"WT"]+a3_G["PV"]*G_W["PV",w]*CF_W[t,w,"PV"])
               +sum{t in 1..T,s in Store}(a3_G["WT"]*G_S["WT",s]*CF_S[t,s,"WT"]+a3_G["PV"]*G_S["PV",s]*CF_S[t,s,"PV"]);                 


#Saling income
param selling_income = sum{f in Factory,t in 1..T}CHP_trade_F[t,f]*Price_DA_F[t,f]
                   + sum{w in Warehouse,t in 1..T}CHP_trade_W[t,w]*Price_DA_W[t,w]
                   + sum{s in Store,t in 1..T}CHP_trade_S[t,s]*Price_DA_S[t,s];


#objective function:
minimize cost:
cap_cost_Gens+cap_cost_ESS+(OM_cost_G+OM_cost_ESS+OM_cost_CHP)-CC_income - selling_income;


#constraint
#meet demand in facto
subject to energy_balance_factory{f in Factory, t in 1..T}:
sum{n in Gens}(G_F["WT",f]*CF_F[t,f,"WT"]+G_F["PV",f]*CF_F[t,f,"PV"])-ESS_E_F[t,f]+ESS_E_F[t-1,f]+CHP_E_F[t,f]>=D_E_F[t,f]+CHP_trade_F[t,f];

subject to energy_balance_warehouse{w in Warehouse, t in 1..T}:
sum{n in Gens}(G_W["WT",w]*CF_W[t,w,"WT"]+G_W["PV",w]*CF_W[t,w,"PV"])-ESS_E_W[t,w]+ESS_E_W[t-1,w]+CHP_E_W[t,w]>=D_E_W[t,w]+CHP_trade_W[t,w];

subject to energy_balance_Store{s in Store, t in 1..T}:
sum{n in Gens}(G_S["WT",s]*CF_S[t,s,"WT"]+G_S["PV",s]*CF_S[t,s,"PV"])-ESS_E_S[t,s]+ESS_E_S[t-1,s]+CHP_E_S[t,s]>=D_E_S[t,s]+CHP_trade_S[t,s];


subject to thermal_balance_factory{f in Factory, t in 1..T}:
        -ESS_T_F[t,f]+ESS_T_F[t-1,f]+CHP_T_F[t,f]=D_T_F[t,f];

subject to thermal_balance_warehouse{w in Warehouse, t in 1..T}:
        -ESS_T_W[t,w]+ESS_T_W[t-1,w]+CHP_T_W[t,w]=D_T_W[t,w];

subject to thermal_balance_Store{s in Store, t in 1..T}:
        -ESS_T_S[t,s]+ESS_T_S[t-1,s]+CHP_T_S[t,s]=D_T_S[t,s];



subject to CHP_MAX_electricity_Factory{f in Factory,t in 1..T}:
                CHP_E_F[t,f]<=CHP_E_F_max[f];                            
subject to CHP_Min_electricity_Factory{f in Factory,t in 1..T}:
                CHP_E_F[t,f]>=CHP_E_F_min[f];               
subject to CHP_MAX_electricity_Warehouse{t in 1..T, w in Warehouse}:
                CHP_E_W[t,w]<=CHP_E_W_max[w];               
subject to CHP_Min_electricity_Warehouse{t in 1..T, w in Warehouse}:
                CHP_E_W[t,w]>=CHP_E_W_min[w];                                              
subject to CHP_MAX_electricity_store{t in 1..T, s in Store}:
                CHP_E_S[t,s]<=CHP_E_S_max[s];                          
subject to CHP_Min_electricity_store{t in 1..T, s in Store}:
                CHP_E_S[t,s]>=CHP_E_S_min[s];  

  
subject to CHP_MAX_thermal_Factory{f in Factory,t in 1..T}:
                CHP_T_F[t,f]<=CHP_T_F_max[f];                            
subject to CHP_Min_thermal_Factory{f in Factory,t in 1..T}:
                CHP_T_F[t,f]>=CHP_T_F_min[f];               
subject to CHP_MAX_thermal_Warehouse{ w in Warehouse,t in 1..T}:
                CHP_T_W[t,w]<=CHP_T_W_max[w];               
subject to CHP_Min_thermal_Warehouse{ w in Warehouse,t in 1..T}:
                CHP_T_W[t,w]>=CHP_T_W_min[w];                                               
subject to CHP_MAX_thermal_store{t in 1..T, s in Store}:
                CHP_T_S[t,s]<=CHP_T_S_max[s];                          
subject to CHP_Min_thermal_store{t in 1..T, s in Store}:
                CHP_T_S[t,s]>=CHP_T_S_min[s];   
                


subject to ESS_Max_electricity_Factory{t in steps, f in Factory}:
            #    ESS_E_F[t,f]<=ESS_E_F_max[f];  
                ESS_E_F[t,f]<=ESS_F[f]; 
subject to ESS_Min_electricity_Factory{t in steps, f in Factory}:
                ESS_E_F[t,f]>=ESS_E_F_min[f];                                  
subject to ESS_Max_electricity_Warehouse{t in steps, w in Warehouse}:
           #     ESS_E_W[t,w]<=ESS_E_W_max[w];  
                ESS_E_W[t,w]<=ESS_W[w];                        
subject to ESS_Min_electricity_Warehouse{t in steps, w in Warehouse}:
                ESS_E_W[t,w]>=ESS_E_W_min[w];  
subject to ESS_Max_electricity_store{t in steps, s in Store}:
               # ESS_E_S[t,s]<=ESS_E_S_max[s]; 
                    ESS_E_S[t,s]<=ESS_S[s];                                                                        
subject to ESS_Min_electricity_store{t in steps, s in Store}:
                ESS_E_S[t,s]>=ESS_E_S_min[s];               
 
                
subject to Transfer_effency_Factory{t in 1..T, f in Factory}:
      CHP_T_F[t,f] =CHP_E_F[t,f]* CHP_EtoT_eff;                      
subject to Transfer_effency_Warehouse{t in 1..T, w in Warehouse}:
      CHP_T_W[t,w] =CHP_E_W[t,w]* CHP_EtoT_eff;      
subject to Transfer_effency_store{t in 1..T, s in Store}:
      CHP_T_S[t,s] =CHP_E_S[t,s]* CHP_EtoT_eff;      
                             
    
#subject to initial_state_f{f in Factory, t in steps}:
#              ESS_E_F[0,f]=ESS_F[f];            
#subject to initial_state_w{w in Warehouse,t in steps}:
#              ESS_E_W[0,w]=ESS_W[w];                    
#subject to initial_state_s{s in Store,t in steps}:
#              ESS_E_S[0,s]=ESS_S[s];          


subject to TS_MAX_thermal_Factory{f in Factory,t in steps}:
                ESS_T_F[t,f]<=ESS_T_F_max[f];                            
subject to TS_Min_thermal_Factory{f in Factory,t in steps}:
                ESS_T_F[t,f]>=ESS_T_F_min[f];               
subject to TS_MAX_thermal_Warehouse{ w in Warehouse,t in steps}:
               ESS_T_W[t,w]<=ESS_T_W_max[w];               
subject to TS_Min_thermal_Warehouse{w in Warehouse,t in steps}:
               ESS_T_W[t,w]>=ESS_T_W_min[w];                                               
subject to TS_MAX_thermal_store{s in Store,t in steps}:
                ESS_T_S[t,s]<=ESS_T_S_max[s];                          
subject to TS_Min_thermal_store{t in steps, s in Store}:
                ESS_T_S[t,s]>=ESS_T_S_min[s];   
                
              
#subject to initial_T_state_f{f in Factory, t in steps}:
#              ESS_T_F[0,f]=30;            
#subject to initial_T_state_w{w in Warehouse,t in steps}:
#              ESS_T_W[0,w]=30;                    
#subject to initial_T_state_s{s in Store,t in steps}:
#              ESS_T_S[0,s]=30;      
              
              
                       