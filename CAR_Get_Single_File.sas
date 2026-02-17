/********************************************************************************************/
/* Instructions :                                                                           */
/* If you execute the REST API call on a different SAS environment                          */
/* (i.e. not the same Viya instance, where Clinical Acceleration is located)                */
/* then ensure that you have previously obtained the &car_token                             */
/* This is not necessary, if you execute the REST API Call from the same SAS Viya           */
/* instance, where your Clinical Acceleration Repository is located                         */
/*                                                                                          */
/* Before interacting with an item in the Clinical Repository Repository                    */
/* (i.e. a folder or an object) you will need to retrive the ID of this element             */
/* Make sure, you have already populated the &car_itemid global macro variable              */
/*                                                                                          */
/* Macro Parameters :                                                                       */
/*       url           : The URL of your CAR instance                                       */                                                    
/*       auth          : Yes / No - Is authentication needed                                */
/*       fileid        : The ID of the single element in the repository, you are            */
/*                       downloading (previously retrieved in the &car_itemid global macro  */
/*                       variable)                                                          */
/*       outpath       : The path of the file server or SAS compute location, where you     */
/*                       want to write the single element from the Clinical Acceleration    */
/*                       Repository to                                                      */
/*       outdata       : The output name of the single element from the Clinical            */
/*                       Acceleration Repository you are downloading                        */
/*       computeserver : Yes / No - specifiy, if you are writing the file to a compute      */
/*                       server or file server location                                     */
/*                                                                                          */
/* Returned value      :                                                                    */
/*       Element from Clinical Acceleration Repository, downloaded to your &outpath         */
/*       location                                                                           */
/*                                                                                          */
/*  YAML File            :                                                                  */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent      */
/*                                                                                          */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.               */
/* SPDX-License-Identifier: Apache-2.0                                                      */
/********************************************************************************************/

%macro car_get_single_file (url=, outpath=, outdata=, fileid=, computeserver=Yes, auth=No);

/********************************************************************************************/
/* Disable cookie caching for PROC HTTP                                                     */
/********************************************************************************************/
                                             
   %let PROCHTTP_NOCOOKIES=1;

/********************************************************************************************/
/* Allocate the temporary output location for the JSON file, returned from the              */
/* REST API Call (PROC HTTP)                                                                */
/********************************************************************************************/

   filename resp;
   libname lsafJson clear;

   %if %upcase(&computeserver)=YES %then %do;

/********************************************************************************************/
/* Output location is on a SAS Compute Server                                               */
/********************************************************************************************/

      filename myfile "&outpath./&outdata.";

   %end;
   %else %do;

/********************************************************************************************/
/* Output location is on a SAS File Server                                                  */
/********************************************************************************************/

      filename myfile filesrvc 
      folderpath="&outpath"
      filename="&outdata"
      ;

    %end;

/***************************************************************************************/
/* Execute the REST API call from a different SAS environment (i.e. not where the      */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

   %if %upcase(&auth)=YES %then %do;

      proc http
         url="&url/clinicalRepository/repository/items/&fileid/content"
         method="POST"
         out=myfile;
         headers 
         "Authorization"="Bearer &car_token."
         "Content-Type"="application/json";
      run;

   %end;
   %else %do;

/***************************************************************************************/
/* Execute the REST API call from the same SAS environment (i.e. where the             */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         method="POST"
         url="&url/clinicalRepository/repository/items/&fileid/content"
         oauth_bearer=sas_services 
         verbose
         out=myfile;
         headers
         "Content-Type"="application/json";
      run;

   %end;
   %put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;

   %if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;

      %PUT *****************************************************;
      %PUT * FILE DOWNLOADED TO &outpath/&outdata              *;
      %PUT *****************************************************;

   %end;
   %else %do;

      %PUT *****************************************************;
      %PUT * FILE NOT DOWNLOADED                               *;
      %PUT *****************************************************;

   %end;

   filename myfile clear ;

%mend;
