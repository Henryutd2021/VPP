param T;

param cf;
param co;
param cm{1..T};
param pres{1..T};
param pel{1..T};
param pthl{1..T};
param pechpmax;
param pechpmin;
param pesmax;
param pesmin;
param pthchpsmax;
param pthchpsmin;



var pmda{1..T} >=0;
var pechp{1..T} <= pechpmax, >= pechpmin;
var pes_ch{1..T} >= 0;
var pes_dis{1..T}  >= 0;
var se{0..T} <= pesmax, >= pesmin;
var sth{0..T} <= pthchpsmax, >= pthchpsmin;
var ths_ch{1..T} >= pthchpsmin, <= pthchpsmax;
var ths_dis{1..T} >= pthchpsmin, <= pthchpsmax;




minimize total_cost: sum{j in 1..T}(pechp[j]*cf + pes_ch[j]*co + pes_dis[j]*co - pmda[j]*cm[j]);

subject to e{j in 1..T}:pechp[j]-pes_ch[j]+pes_dis[j]+pres[j]-pmda[j]=pel[j];
subject to th{j in 1..T}:0.8*pechp[j]-ths_ch[j]+ths_dis[j]=pthl[j];

subject to e_s{j in 1..T}:
    se[j]=se[j-1]+pes_ch[j]-pes_dis[j];
 
subject to se_0: se[0]=0;

subject to th_s{j in 1..T}:
	sth[j]=sth[j-1]+ths_ch[j]-ths_dis[j];

subject to ths_0: sth[0]=0;

































