/*Data Import*/
PROC IMPORT DATAFILE="/home/u59406283/AdventureWorks.xlsx"
		    OUT=WORK.Product
		    DBMS=XLSx
		    REPLACE;
		    SHEET= "Product";
		    GETNAMES=YES;
RUN;
PROC IMPORT DATAFILE="/home/u59406283/AdventureWorks.xlsx"
		    OUT=WORK.SalesOrderDetail
		    DBMS=XLSx
		    REPLACE;
		    SHEET= "SalesOrderDetail";
		    GETNAMES=YES;
RUN;
PROC PRINT DATA=WORK.SalesOrderDetail (obs=20); RUN;
PROC PRINT DATA=WORK.Product (obs=20); RUN;
proc contents data=WORK.SalesOrderDetail; run;
proc contents data=WORK.Product; run;
/*Data Cleaning Product_Clean*/
proc format;
value $Cfmt ' ' = "NA" default= $12.;
data Product_Clean ;
	set WORK.Product (keep= ProductID Name ProductNumber Color ListPrice);
	Num_ListPrice = input (ListPrice, dollar10.2);
	drop ListPrice;
	rename Num_ListPrice = ListPrice;
run;
proc print data=Product_Clean (obs=20);
	format Color $Cfmt. ListPrice dollar10.2; run;
/*Data Cleaning SalesOrderDetail_Clean*/
data SalesOrderDetail_Clean;
	set WORK.SalesOrderDetail
	(keep = SalesOrderID SalesOrderDetailID OrderQty ProductID UnitPrice LineTotal ModifiedDate);
	Date = input (ModifiedDate, anydtdtm.);
	Num_ModifiedDate = datepart (Date);
	format Num_ModifiedDate mmddyy10.;
	Num_UnitPrice = input (UnitPrice, dollar10.2);
	Num_LineTotal = input (LineTotal, dollar10.2);
	Num_OrderQty = input (OrderQty, 10.) ;
	drop UnitPrice ModifiedDate LineTotal OrderQty Date;
	rename Num_ModifiedDate = ModifiedDate;
	rename Num_UnitPrice = UnitPrice;
	rename Num_LineTotal = LineTotal;
	rename Num_OrderQty = OrderQty;
run;
proc print data=SalesOrderDetail_Clean
(where= (ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd)obs=20);
	id SalesOrderDetailID;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ModifiedDate mmddyy10.; run;
/*Joining and Merging*/
proc sort data=SalesOrderDetail_Clean; by ProductID; run;
proc sort data=Product_Clean; by ProductID; run;
data SalesDetails;
	merge SalesOrderDetail_Clean (in = S1) 
	Product_Clean (in = S2);
	by ProductID;
	if S1 = 1 and S2 = 1;
	drop SalesOrderID SalesOrderDetailID ProductNumber ListPrice;
run;
proc print data=SalesDetails (obs=20 ); 
	var ProductID ModifiedDate UnitPrice LineTotal OrderQty Name Color;
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*Sales Analysis*/
proc sort data=SalesDetails out=SalesAnalysis;
    by ProductID;
run;
data totalby;
	set SalesAnalysis;
	by ProductID;
	if first.ProductID then SubTotal = 0; 
	SubTotal + LineTotal;
	if last.ProductID then output;
	format SubTotal dollar10.2;
run;
proc print data=totalby (obs=20);
	format SubTotal dollar10.2; 
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*data analysis*/
/*question1*/
data one;
	set SalesAnalysis;
	where Name like "%Helmet%" and Color = 'Red' and 
	ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd ; run;
data _null_;
	put nobs=;
	stop;
	set one nobs=nobs;
run;
proc print data=one (obs=20);
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.;  run;
/*question2*/
data two;
	set SalesAnalysis;
	where Color = 'Multi' and ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd ; run;
data _null_;
	put nobs=;
	stop;
	set two nobs=nobs;
run;
proc print data=two (obs=20);
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*question3*/
proc sort data=SalesAnalysis out=Analysis;
    by ModifiedDate; run;
data three;
	set Analysis;
	where Name like "%Helmet%" and ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd ;
	by ModifiedDate;
	if first.ModifiedDate then SubTotal = 0; 
	SubTotal + LineTotal;
	if last.ModifiedDate then output;
	format SubTotal dollar10.2; run;
data _null_;
	put nobs=;
	stop;
	set three nobs=nobs; run;
proc print data=three (obs=20);
	format SubTotal dollar10.2; 
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*question4*/
data four;
	set SalesAnalysis;
	where Color = "Yellow" and Name like "%Touring-1000%" and 
	ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd ; run;
data _null_;
	put nobs=;
	stop;
	set four nobs=nobs;
run;
proc print data=four (obs=20);
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*question5*/
data five;
	set SalesAnalysis;
	where ModifiedDate>='01jan2013'd and ModifiedDate<'01jan2015'd ; run;
data _null_;
	put nobs=;
	stop;
	set five nobs=nobs;
run;
proc print data=five (obs=20);
	format Color $Cfmt.;
	format UnitPrice dollar10.2 LineTotal dollar10.2 ;
	format ModifiedDate mmddyy10.; run;
/*bar chart*/
proc sgplot data=SalesAnalysis;
	vbar Color;
	title "Number of Products by Color"; run; quit;
proc sgplot data=SalesAnalysis;
	vbar OrderQty;
	title "Number of Products by Quantity"; run; quit;