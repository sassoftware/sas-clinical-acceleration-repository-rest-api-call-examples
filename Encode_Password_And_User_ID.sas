/***************************************************************************************/
/* Instructions :                                                                      */
/* Store your encoded user id and password information in a .txt file                  */
/* These files can be utilized for the authentication process                          */
/*                                                                                     */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.          */
/* SPDX-License-Identifier: Apache-2.0                                                 */
/***************************************************************************************/

%macro encode_pw_and_user_id (pwfile=, usrfile=, userid=, pw=);

   filename pwfile "&pwfile";
   filename usrfile "&usrfile";

   proc pwencode in="&pw" out=pwfile;
   run;

   proc pwencode in="&userid" out=usrfile;
   run;

%mend;

%encode_pw_and_user_id (pwfile=/nfsshare/sashls/home/schdac/CAR_Demo/pw.txt, 
                        usrfile=/nfsshare/sashls/home/schdac/CAR_Demo/usr.txt, 
                        userid=schdac, 
                        pw=schdac);
