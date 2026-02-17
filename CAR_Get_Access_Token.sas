/***************************************************************************************/
/* Instructions :                                                                      */
/* If you execute the REST API call on a different SAS environment                     */
/* (i.e. not the same Viya instance, where Clinical Acceleration is located)           */
/* you will need to retrieve an authentication token                                   */
/*                                                                                     */
/* Macro Parameters :                                                                  */
/*       url      : The URL of your CAR instance                                       */
/*       usr      : Your user name                                                     */
/*       pw       : Your user password                                                 */
/*                                                                                     */
/* Returned value :                                                                    */
/*       &car_token : Contains the authentication token for all REST API calls         */
/*                                                                                     */
/*  YAML File            :                                                             */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent */
/*                                                                                     */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.          */
/* SPDX-License-Identifier: Apache-2.0                                                 */
/***************************************************************************************/

/***************************************************************************************/
/* GET CAR ACCESS TOKEN                                                                */
/***************************************************************************************/

%macro car_get_access_token(url=, usr=, pw=);

   %global car_token;

/***************************************************************************************/
/* If the certificate for your Clinical Acceleration Instance is not installed         */
/* then set this option, to allow SAS to continue with the execution of the program    */
/***************************************************************************************/
	
    options set=SSLREQCERT="allow"; 

/***************************************************************************************/
/* Allocate the temporary output location for the JSON file, returned from the         */
/* REST API Call (PROC HTTP)                                                           */
/***************************************************************************************/

	filename resp temp;

/***************************************************************************************/
/* Execute the REST API Call to your Clinical Acceleration Repository Instance         */
/***************************************************************************************/

	proc http url="&url/SASLogon/oauth/token"
		method="POST"
		in="grant_type=password%nrstr(&username)=&usr%nrstr(&password)=&pw"
		out=resp;
		headers "Authorization"="Basic c2FzLmVjOg==";
	run;

	%put PROC HTTP STATUS: &SYS_PROCHTTP_STATUS_CODE. &SYS_PROCHTTP_STATUS_PHRASE.;

	%if ("&SYS_PROCHTTP_STATUS_CODE." eq "200") %then %do;
		%put Logon was successful.;
		libname lsafJson JSON fileref=resp;

		data response;
			set lsafJson.alldata;

/***************************************************************************************/
/* Store the access tokein in the global macro variable &access_token                  */
/***************************************************************************************/

			if (strip(p1)="access_token") then call symputx("car_token", value, 'G');
		run;

		%PUT *****************************************************;
		%PUT * ACCESS TOKEN ISSUED *;
		%PUT *****************************************************;
		%put &=car_token;
	%end;
	%else %do;
		%PUT *****************************************************;
		%PUT * ACCESS TOKEN NOT ISSUED *;
		%PUT *****************************************************;
	%end;
	filename resp;
	libname lsafJson clear;
%mend;



