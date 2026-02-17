/********************************************************************************************/
/* Instructions :                                                                           */
/* If you execute the REST API call on a different SAS environment                          */
/* (i.e. not the same Viya instance, where Clinical Acceleration is located)                */
/* then ensure that you have previously obtained the &car_token                             */
/* This is not necessary, if you execute the REST API Call from the same SAS Viya           */
/* instance, where your Clinical Acceleration Repository is located                         */
/*                                                                                          */
/* Before interacting with a folder in the Clinical Repository Repository                   */
/* you will need to retrive the ID of this element                                          */
/* Make sure, you have already populated the &car_itemid global macro variable              */
/*                                                                                          */
/* Macro Parameters :                                                                       */
/*       url           : The URL of your CAR instance                                       */                                                    
/*       auth          : Yes / No - Is authentication needed                                */
/*       outdata       : The SAS Dataset, where the audit trail information is written to   */ 
/*                                                                                          */
/* Returned value      :                                                                    */
/*       The SAS Dataset, which contains the audit trail data                               */
/*                                                                                          */
/*  YAML File            :                                                                  */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent      */
/*                                                                                          */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.               */
/* SPDX-License-Identifier: Apache-2.0                                                      */
/********************************************************************************************/

%macro car_read_audit_information(url=, auth=, outdata=);

/********************************************************************************************/
/* Disable cookie caching for PROC HTTP                                                     */
/********************************************************************************************/

   %let PROCHTTP_NOCOOKIES=1;

/********************************************************************************************/
/* Allocate the temporary output location for the JSON file, returned from the              */
/* REST API Call (PROC HTTP)                                                                */
/********************************************************************************************/

   filename resp temp;
   libname lsafJson clear;

   %if %upcase(&auth)=YES %then %do;

/***************************************************************************************/
/* Execute the REST API call from a different SAS environment (i.e. not where the      */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         url="&url/clinicalRepository/audit/entries"
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
         url="&url/clinicalRepository/audit/entries"
         oauth_bearer=sas_services 
         verbose
         out=resp
        ;
      run;

   %end;

   %put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;
   
   %if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;
      %put Logon was successful.;
	  libname lsafJson JSON fileref=resp;
 
	  data &outdata;
	     set lsafJson.alldata;
      run;
 
   %end;
   %else %do;
      
      %PUT *************************************************;
      %PUT * Audit Trail Retrieval Was Not Succesful       *;
      %PUT *************************************************;

   %end;
%mend;
