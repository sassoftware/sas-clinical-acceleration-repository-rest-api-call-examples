/***************************************************************************************/
/* Instructions :                                                                      */
/* Ensure that you ave your encoded user id and password information in a .txt file    */
/* These files can be utilized for the authentication process                          */
/*                                                                                     */
/* Macro Parameters :                                                                  */
/*       usrfile  : The location of the .txt file which contains your encoded user id  */
/*       pwfile   : The location of the .txt file which contains your encoded user id  */
/*                                                                                     */
/* Returned value :                                                                    */
/*       &pw      : Contains the encoded password                                      */
/*       &name    : Contains the encoded user name                                     */
/*                                                                                     */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.          */
/* SPDX-License-Identifier: Apache-2.0                                                 */
/***************************************************************************************/

/*************************************************************/
/* GET CAR ACCESS TOKEN                                      */
/*************************************************************/

%macro Get_Encoded_Credentials (usrfile=, pwfile=);

   %global pw name;

   filename pwfile "&pwfile";
   filename usrfile "&usrfile";

   data _null_;
      infile pwfile obs=1 length=l; 
      input @;
      input @1 line $varying1024. l; 
      call symput('pw',substr(line,1,l)); 
   run;

   data _null_;
      infile usrfile obs=1 length=l; 
      input @;
      input @1 line $varying1024. l; 
      call symput('name',substr(line,1,l)); 
   run;

%mend;
