/********************************************************************************************/
/* Instructions :                                                                           */
/* Load your data into CAS for further visualization or processing with SAS Viya            */
/*                                                                                          */
/* Macro Parameters :                                                                       */
/*       caslib        : The Output CAS Library                                             */                                                    
/*       inlib         : The SAS Compute Library, where your SAS dataset is located         */
/*                       that will be uploaded to CAS                                       */
/*       indata        : The name of the SAS dataset you want to upload to CAS              */
/*       outdata       : The name of the output table in CAS                                */                                                       
/*       global_scope  : YES / NO - should the table be available globally                  */
/*                                                                                          */
/* Returned value      :                                                                    */
/*       SAS Table loaded into CAS                                                          */
/*                                                                                          */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.               */
/* SPDX-License-Identifier: Apache-2.0                                                      */
/********************************************************************************************/

/********************************************************************************/
/* Write Data To CAS                                                            */
/********************************************************************************/

%macro CAR_Write_To_CAS (caslib=casuser, inlib=work, indata=, outdata=, global_scope=Yes);

   proc cas; 
   /*check for session scope table*/
      table.tableexists result = r1 / 
      caslib="&caslib",
      name="&outdata";

   /*drop session scope table*/
      if r1.exists = 1 then do; 
         action table.droptable / 
         caslib="&caslib" 
         name="&outdata"; 
      end; 

   run;
   /*check for global scope table*/
      table.tableexists result = r2 / 
      caslib="&caslib" 
      name="&outdata"; 
   /*drop global scope table*/
      if r2.exists = 2 then do; 
         action table.droptable / 
         caslib="&caslib" 
         name="&outdata"; 
      end; 
   quit;

   data work.temp;
      set &inlib..&indata;
   run;

   proc casutil; load DATA="temp" casout="&outdata" replace;
   quit;

   proc casutil;
      list tables;
   run;

   /*
   By default, in-memory CAS tables have "session" scope, meaning that they are 
   available only within the specific CAS session that you are working with. 
   So to make a table available in a different CAS session (the new CAS session 
   that is created when you use VA), you need to promote the table to be global 
   scope.
   */

   %if &global_scope=Yes %then %do;

      proc cas;
	     action table.promote /
		 caslib="&caslib",
		 table="&outdata";
      run;
      quit;
   %end;
%mend;
