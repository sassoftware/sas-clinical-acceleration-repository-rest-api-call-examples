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
/*       fileid        : The ID of the target folder in the repository, you are             */ 
/*                       uploading the element to (previously retrieved in the &car_itemid  */
/*                       global macro  variable)                                            */
/*       inpath        : The path of the file server or SAS compute location, where you     */
/*                       want to read the element from                                      */                                                
/*       indata        : The name of the element, located on a SAS file server or           */
/*                       a SAS compute location                                             */
/*       outdata       : The name of the output that is written to the repository           */
/*       vtext         : The comment associated to the new version (applies only, if the    */
/*                       element is under version control)                                  */
/*       computeserver : Yes / No - specifiy, if you are reading the file from a compute    */
/*                       server or file server location                                     */
/*                                                                                          */
/* Returned value      :                                                                    */
/*       The item is written to the location in the Repository                              */
/*                                                                                          */
/*  YAML File            :                                                                  */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent      */
/*                                                                                          */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.               */
/* SPDX-License-Identifier: Apache-2.0                                                      */
/********************************************************************************************/

/********************************************************************************/
/* Upload a sepcific dataset                                                    */
/********************************************************************************/

%macro CAR_Upload_Single_File (url=, auth=, inpath=, indata=, outdata=, fileid=, vtext= , computeserver=no);

/********************************************************************************************/
/* Disable cookie caching for PROC HTTP                                                     */
/********************************************************************************************/

   %let PROCHTTP_NOCOOKIES=1;

/********************************************************************************************/
/* Allocate the temporary output location for the JSON file, returned from the              */
/* REST API Call (PROC HTTP)                                                                */
/********************************************************************************************/

   filename resp temp;

    %if %upcase(&computeserver)=YES %then %do;

/********************************************************************************************/
/* Input location is on a SAS Compute Server                                                */
/********************************************************************************************/

       filename myfile2 "&inpath./&indata.";
    %end;
    %else %do;

/********************************************************************************************/
/* Input location is on a SAS File Server                                                   */
/********************************************************************************************/

      filename myfile2 filesrvc 
      folderpath="&inpath"
      filename="&indata"
      encoding="UTF-8"
      ;

   %end;

   %if %upcase(&auth)=YES %then %do;

/***************************************************************************************/
/* Execute the REST API call from a different SAS environment (i.e. not where the      */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         url="&url/clinicalRepository/repository/items/&fileid./content?name=&outdata&comment=&vtext"
         method="PUT"
         out=resp
         in = MULTI FORM ( "uploadFile" = myfile2 header="Content-Type: text/plain"
         ;
         headers 
         "Authorization"="Bearer &car_token.";
      run;

   %end;
   %else %do;

/***************************************************************************************/
/* Execute the REST API call from the same SAS environment (i.e. where the             */
/* the Clinical Acceleration Repository is located)                                    */
/***************************************************************************************/

      proc http
         method="PUT"
         url="&url/clinicalRepository/repository/items/&fileid./content?name=&outdata&comment=&vtext"
         oauth_bearer=sas_services 
         verbose
         out=resp
        ;
      run;

   %end;

   %put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;

   %if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;
      %PUT *****************************************************;
      %PUT * File &inpath &indata written to &outdata          *;
      %PUT *****************************************************;
   %end;

   %else %do;
      %PUT *****************************************************;
      %PUT * Upload to Repository Failed                       *;
      %PUT *****************************************************;
   %end;

%mend;
