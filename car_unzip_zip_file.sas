/**********************************************************************************************/
/* Instructions :                                                                             */
/* The .zip file needs to be located on a SAS Compute Server                                  */
/* If your .zip file is located on a SAS File Server, use the binary copy macro to copy the   */
/* file to a SAS Compute Server.                                                              */
/*                                                                                            */
/* Macro Parameters :                                                                         */
/*       inpath          : The path of the file server or SAS compute location, where you     */
/*                         want to read the .zip file from                                    */
/*       zipfile         : The name of the zipfile, located on a SAS file server or           */
/*                         a SAS compute location                                             */
/*       study_workspace : The location, where the .zip file will be unzipped to.             */
/*       computeserver   : Yes / No - specifiy, if you are reading the .zip file from a       */ 
/*                         compute server or file server location                             */
/*                                                                                            */
/*                         This needs to be on a SAS Workspace Server                         */  
/*                                                                                            */
/* Returned value        :                                                                    */
/*       The unzipped folder, located on the &workspace location                              */
/*                                                                                            */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.                 */
/* SPDX-License-Identifier: Apache-2.0                                                        */
/**********************************************************************************************/

/**********************************************************************************************/
/* Unzip a .zip file                                                                          */
/**********************************************************************************************/

%macro car_unzip_zip_file(inpath=, zipfile=, study_workspace=, computeserver=No);

   %put *************************;
   %put &inpath./&zipfile.;

   %if %upcase(&computeserver)=YES %then %do;

/**********************************************************************************************/
/* Output location is on a SAS Compute Server                                                 */
/**********************************************************************************************/

      %put Executing Compute Server;
      filename inzip ZIP "&inpath./&zipfile.";

   %end;
   %else %do;

/********************************************************************************************/
/* Output location is on a SAS File Server                                                  */
/********************************************************************************************/

      %put Executing File Server;
      filename inzip filesrvc 
      folderpath="&inpath"
      filename="&zipfile"
      ;

   %end;


/********************************************************************************************/
/* Read the content of the .zip file                                                        */
/********************************************************************************************/

   data contents(keep=memname isFolder);
      length memname $200 isFolder 8;
      fid=dopen("inzip");
      put "Fid is" fid;
      if fid=0 then do;
         put "Stopped";
         stop;
      end;
      memcount=dnum(fid);
      put "memcount" memcount;
      do i=1 to memcount;
         memname=dread(fid,i);
         /* check for trailing / in folder name */
         isFolder = (first(reverse(trim(memname)))='/');
         output;
      end;
      rc=dclose(fid);
   run;

/********************************************************************************************/
/* Retain Folder Names                                                                      */
/********************************************************************************************/

   data contents;
      format foldername $200.;
      set contents;
      if isFolder=1 then foldername=memname;
      retain foldername;
   run;

/********************************************************************************************/
/* Remove the Folder Names from the Filenames                                               */
/********************************************************************************************/

   data contents;
      format level 8. level1 level2 level3 level4 level5 level6 level7 level8 level9 $50.;
      set contents;
      if isFolder=0;
      memname=tranwrd(memname, left(trim(foldername)), "");
	  foldername = tranwrd(foldername, "/  ", "");
	  level = countc(foldername, '/')+1;
	  level1=scan(foldername,1,'/');
	  level2=scan(foldername,2,'/');
	  level3=scan(foldername,3,'/');
	  level4=scan(foldername,4,'/');
	  level5=scan(foldername,5,'/');
	  level6=scan(foldername,6,'/');
	  level7=scan(foldername,7,'/');
	  level8=scan(foldername,8,'/');
	  level9=scan(foldername,9,'/');
	  call symputx("level",level);
   run;

   data contents;
      format libname $8.; 
      set contents;
	  libname=level&level;
   run;

/********************************************************************************************/
/* Create Folder Structure From .zip File                                                   */
/********************************************************************************************/

   data temp;
      set contents;
   run;

   proc sort data=temp nodupkey; by foldername; run;

   data _NULL_;
      set temp;
	  call symputx("nobs",_N_);
   run;

/********************************************************************************************/
/* Unzip the .zip file                                                                      */
/********************************************************************************************/

   %do i=1 %to &nobs;

      data temp2;
	     format currlevel $350.;
	     set temp;
		 if _N_= &i;
         currlevel=left(trim("&study_workspace"));
		 call symputx("level",level);
      run;

	  %do j=1 %to &level;
	     
	     data temp2;
			set temp2;
			currlevel=left(trim(currlevel))||"/"||left(trim(level&j));
			call symputx("currlevel",left(trim(currlevel)));
		 run;

		 options dlcreatedir;
         %PUT ***** Creating Folder &currlevel;
         libname newdir "&currlevel";

	  %end;
   %end;
   
   data _NULL_;
      set contents;
      call symputx("Nobs",_N_);
   run;

   %do i=1 %to &Nobs;
     
      data _NULL_;
         set contents;
         if _N_=&i;
         if libname='' then libname="temp";
         call symputx("dsn_name",left(trim(memname)));
		 call symputx("foldername",left(trim(foldername)));
		 call symputx("libname",left(trim(libname)));
		 if index(memname,'sas7bdat') then call symputx("infile","Data");
		 else call symputx("infile","File");
      run;

      
      %put *** The input file format is &foldername\&dsn_name &infile - Now Copying &dsn_name in observation &i;
    
	  /* if you want to copy the data to your work library   */
      /* filename ds "%sysfunc(getoption(work))/&dsn_name" ; */

	     filename ds "&study_workspace/&foldername/&dsn_name";
		 libname &libname "&study_workspace/&foldername";

         data _null_;
            /* reference the member name WITH folder path */
            infile inzip(&foldername/&dsn_name)
	        lrecl=256 recfm=F length=length eof=eof unbuf;
            file   ds lrecl=256 recfm=N;
            input;
            put _infile_ $varying256. length;
            return;
            eof:
            stop;
         run;
   %end;
%mend;




