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
/*Multiple files are downloaded to a zip file                                               */
/* Macro Parameters :                                                                       */
/*       url           : The URL of your CAR instance                                       */                                                    
/*       auth          : Yes / No - Is authentication needed                                */
/*       fileid        : The ID of the single element in the repository, you are            */
/*                       edownloading (previously retrieved in the &car_itemid              */
/*                       global macro)                                                      */
/*                       variable)                                                          */
/*      outpath        : The path of the file server or SAS compute location, where you     */
/*                       want to write the multiple elements from Clinical Acceleration     */
/*                      Repository to (as a .zip file)                                      */                  
/*       zipfile       : The name of the .zip file, located on a SAS file server or         */
/*                       a SAS compute location                                             */
/*       computeserver : Yes / No - specifiy, if you are writing the file to a compute      */
/*                       server or file server location                                     */
/*                                                                                          */
/* Returned value      :                                                                    */
/*       Zip file from Clinical Acceleration Repository, download to your &zipfile          */
/*       location                                                                           */
/*                                                                                          */
/*  YAML File            :                                                                  */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent      */
/*                                                                                          */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.               */
/* SPDX-License-Identifier: Apache-2.0                                                      */
/********************************************************************************************/

/********************************************************************************/
/* Download multiple items from CAR                                                        */
/********************************************************************************/

%macro car_get_multiple_files(url=, outpath=, zipfile=, fileid=, computeserver=No, auth=No);

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
/* Output location is on a SAS Compute Server                                                */
/********************************************************************************************/

   filename myfile "&outpath./&zipfile.";

   %end;
   %else %do;

/********************************************************************************************/
/* Output location is on a SAS File Server                                                   */
/********************************************************************************************/

   filename myfile2 filesrvc 
   folderpath="&outpath"
   filename="&zipfile"
   ;

  %end;

   %if %upcase(&auth)=YES %then %do;

/***************************************************************************************/
/* Execute the REST API call from a different SAS environment (i.e. not where the      */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

   proc http
      url="&url/clinicalRepository/repository/items/&fileid./content?expand=true"
      method="PUT"
	  out=resp
	  in = MULTI FORM ( "uploadFile" = myfile2 header="Content-Type: text/plain");
	  headers
	  "Authorization"="Bearer &car_token.";
      debug level=3;
   run;

   %end;
   %else %do;

/***************************************************************************************/
/* Execute the REST API call from the same SAS environment (i.e. where the             */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         method="POST"
         url="&url/clinicalRepository/repository/items/&car_item./content"
         oauth_bearer=sas_services 
         verbose
         out=myfile;
	     "Content-Type"="application/json";
         debug level=3;
      run;

   %end;

   %put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;

   %if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;

      %PUT *****************************************************;
      %PUT * File DOWNLOADED TO &outpath &zipfile        *;
      %PUT *****************************************************;

	  %put &=outpath;
   %end;
   %else %do;
      %PUT *****************************************************;
      %PUT * FILE NOT DOWNLOADED                     *;
      %PUT *****************************************************;
   %end;

   filename myfile clear ;

%mend;
