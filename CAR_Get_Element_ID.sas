/***************************************************************************************/
/* Instructions :                                                                      */
/* If you execute the REST API call on a different SAS environment                     */
/* (i.e. not the same Viya instance, where Clinical Acceleration is located)           */
/* then ensure that you have previously obtained the &car_token                        */
/* This is not necessary, if you execute the REST API Call from the same SAS Viya      */
/* instance, where your Clinical Acceleration Repository is located                    */
/*                                                                                     */
/* Before interacting with an item in the Clinical Repository Repository               */
/* (i.e. a folder or an object) you will need to retrive the ID of this element        */
/*                                                                                     */
/* Macro Parameters :                                                                  */
/*       url      : The URL of your CAR instance                                       */                                                    
/*       auth          : Yes / No - Is authentication needed                           */
/*       car_item : The location of the element in the repository, you are interacting */
/*                  with                                                               */
/*                                                                                     */
/* Returned value :                                                                    */
/*       &car_itemid : Contains the Item ID of the element in the repository           */
/*                     you are interacting with (folder or an object)                  */
/*                                                                                     */
/*  YAML File            :                                                             */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent */
/*                                                                                     */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.          */
/* SPDX-License-Identifier: Apache-2.0                                                 */
/***************************************************************************************/

/***************************************************************************************/
/* Get File ID from a Specific Item in CAR                                             */
/***************************************************************************************/

%macro car_get_element_id (url=, auth=No, car_item=);

/***************************************************************************************/
/* Allocate the temporary output location for the JSON file, returned from the         */
/* REST API Call (PROC HTTP)                                                           */
/***************************************************************************************/

   filename resp temp;

   %global car_itemid;

   %if %upcase(&auth)=YES %then %do;

/***************************************************************************************/
/* Execute the REST API call from a different SAS environment (i.e. not where the      */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         url="&url/clinicalRepository/repository/items?filter=eq(path,'&car_item')"
	     method="GET"
	     out=resp;
	     headers "Authorization"="Bearer &car_token.";
      run;

   %end;
   %else %do;

/***************************************************************************************/
/* Execute the REST API call from the same SAS environment (i.e. where the             */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         method="GET"
         url="&url/clinicalRepository/repository/items?filter=eq(path,'&car_item')"
         oauth_bearer=sas_services 
         verbose
         out=resp
        ;
      run;

   %end;

   %put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;

   data _null_;
      infile resp;
      input;
      put _infile_;
   run;

/***************************************************************************************/
/* Populate the global macro variable &car_itemid                                      */
/***************************************************************************************/

   %if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;
      libname lsafJson JSON fileref=resp;

	  data CAR_Items;
	     set lsafJson.alldata;
		 if (strip(p2)="id") then call symputx("car_itemid",value);
         if (strip(p2)="path") then call symputx("path",value);
	  run;
      
      %PUT *****************************************************;
      %PUT * FILE ID RETRIEVED                                 *;
      %PUT *****************************************************;
      
      %put &=car_item;
      %put &=car_itemid;
   %end;
   %else %do;

      %PUT *****************************************************;
      %PUT * FILE NOT FOUND                                    *;
      %PUT *****************************************************;

   %end;

%mend;

