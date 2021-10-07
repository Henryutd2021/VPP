model;
                      
#param M;       #Set of manufacturing plants m 
set prods:={"WT", "PV"};       #Set of renewable generation product types  
set HESS:={"BS", "SC"};       #Set of renewable generation product types  
param T:=8760;
#set steps ordered;                       #Set of time periods (t=8760) 
set periods:= 0..T by 24 ordered;
set steps:=1..T by 1 ordered; 

param Y;                              # 20 years investment  
param r;                              # interest rate
param Q=(r*(1+r)^Y)/((1+r)^Y-1);      # 20 year(20,0.5)=0.0802 
param Alpha;                          # Loss of power supply probability criterion <0.001
#param Delta;                         # Wind abandon criterion<0.01
#param mean;                          # mean load MW
#param sigma;                         # sandard devision
param a1_G{n in prods};               #capacity cost OF renewable generators
param a1_HESS{j in HESS};             #capacity cost OF renewable generators
param a2_G{n in prods};               # O/M cost OF renewable generators
param a2_HESS;                        # O/M cost OF renewable generators
param a3_G;                           # carbon credit of each location and each generation
param D{t in steps};                   # random load MW at t time
param Coff_WT{t in steps};
param Coff_PV{t in steps};
param c_buy{t in steps}; #Energy price for the manufacring at t time; 
#param c_sale{t in steps}=0.3*c_buy[t]; # Saling surplus energy price in period ;
param c_sale=35; # Saling surplus energy price in period ;


#Coefficient of                                    
param SOC_min{j in HESS};
param SOC_max{j in HESS};
param SOC_ini{j in HESS};
param HESS_capacity{j in HESS};
param DoD;

##variable ##
var P_G{n in prods}>=0;                # capacity of generation
var P_HESS{j in HESS}>=0;              # capacity of HESS                 
var E_jt{j in HESS,t in steps};
var E_Ch_jt{j in HESS,t in steps}>=0;             # charging process
var E_Disch_jt{j in HESS,t in steps}>=0;          # Discharging process
var P_buy{t in steps}>=0;                         # purchase anount energy at t
var P_sale{t in steps}>=0;
var P_buy_pos{t in steps}binary;                     # purchase energy status at t,Y_j=1

#Capacity cost
var cost_cap_G=sum{n in prods}Q*a1_G[n]*P_G[n];
var cost_cap_HESS=sum{j in HESS}Q*a1_HESS[j]*P_HESS[j];

# Maintance cost for battery only consider charging process
var OM_cost_G=sum{t in steps}(a2_G["WT"]*P_G["WT"]*Coff_WT[t]+a2_G["PV"]*P_G["PV"]*Coff_PV[t]);

var OM_cost_HESS=sum{t in steps}E_Disch_jt["BS",t]*a2_HESS;
var carbontax_reward=sum{t in steps}P_G["WT"]*Coff_WT[t]*a3_G;
var Cost_buy=sum{t in steps}P_buy[t]*c_buy[t];
var Income_sale=sum{t in steps}P_sale[t]*c_sale;
var save=sum{t in 1..T}(D[t]-P_buy[t])*c_buy[t];
#param save=sum{t in steps}D[t]*c_buy[t];
var generation=sum{t in steps}(P_G["WT"]*Coff_WT[t]+P_G["PV"]*Coff_PV[t]);


##objective function##
minimize cost:
(cost_cap_G+cost_cap_HESS+OM_cost_G+OM_cost_HESS-carbontax_reward+Cost_buy-Income_sale)
;	

##constrain:
#Initial value of SOE
subject to initial_state{j in HESS}:
     E_jt[j,1] = P_HESS[j]*SOC_max[j];

subject to end_status{j in HESS}:
     E_jt[j,T] =P_HESS[j]*SOC_max[j];

#subject to end_status{j in HESS, t in periods:ord(t)>1}:
#     E_jt[j,t]= P_HESS[j]*SOC_max[j];
          
subject to SOC_MAX {j in HESS,t in steps}:
     E_jt[j,t]-SOC_max[j]* P_HESS[j]<=0;
 
subject to SOC_MIM {j in HESS,t in steps}:
    E_jt[j,t]-SOC_min[j]*P_HESS[j]>=0;

subject to SOC_Process{j in HESS,t in steps:ord(t)>1}:
    E_jt[j,t]=E_jt[j,t-1]+E_Ch_jt[j,t]-E_Disch_jt[j,t];

#zero emitation
subject to energy_conservation:
	sum{t in steps}(P_G["WT"]*Coff_WT[t]+P_G["PV"]*Coff_PV[t])+sum{t in steps}P_buy[t]-sum{t in steps}P_sale[t]=sum{t in steps}D[t];

#energy conservation at any t time
subject to anytimeEnery_onservation{t in steps}:
	P_G["WT"]*Coff_WT[t]+P_G["PV"]*Coff_PV[t]+P_buy[t]-P_sale[t]+sum{j in HESS}(E_Disch_jt[j,t]-E_Ch_jt[j,t])=D[t];

subject to P_buy_pos_defn{t in steps}: 
	P_buy[t] <= 50*P_buy_pos[t];

subject to buy_times:
	sum{t in steps}P_buy_pos[t]<=T*Alpha;

subject to buy_amount:
  sum{t in steps}P_buy[t]<=sum{t in steps}P_sale[t];
               
#subject to charging_discharging{j in HESS, t in 1..T}:
#     Yout_jt[j,t]+Yin_jt[j,t]<=1;    


#subject to buy_times:
#	count{t in 1..T}(P_buy[t]<0) <= T*Alpha;


