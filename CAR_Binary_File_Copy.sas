/**********************************************************************************************/
/* Instructions :                                                                             */
/* This program is used, to copy any file from a SAS File Server to a SAS Compute Server and  */
/* vice versa                                                                                 */                                                             
/*                                                                                            */
/* Macro Parameters :                                                                         */
/*       infile          : The Filename statement, that points to the file that will be copied*/
/*       outfile         : The Filename statement, that points to the target location         */                                          
/*       returnName      : The Variable for the Return message                                */
/*       chunkSize       : The size of the 'chuncks' that are copied                          */
/*                                                                                            */
/*  YAML File            :                                                                    */
/*     https://developer.sas.com/rest-apis/clinicalRepository/putRepositoryItemContent        */
/*                                                                                            */
/* Copyright © 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.                 */
/* SPDX-License-Identifier: Apache-2.0                                                        */
/**********************************************************************************************/
/**********************************************************************************************/
/* Copy from a File System to Library and vice versa                                          */
/**********************************************************************************************/

%macro CAR_Binary_File_Copy(
    infile=_bcin
  , outfile=_bcout
  , returnName=_bcrc
  , chunkSize=16392
);

  %local
    startTime
    endTime
    diffTime
  ;

  %let startTime = %sysfunc( datetime() );

  %if %sysevalf( &chunkSize > 32767 ) = 1 %then %do;
    %put NOTE: &sysMacroname chunksize > 32767, setting it to 32767;
    %let chunksize = 32767;
  %end; 

  %put NOTE: &sysMacroname start %sysfunc( putn(&startTime, datetime19.));
  %put NOTE: &sysMAcroname infile=&infile %qsysfunc(pathname(&infile));
  %put NOTE: &sysMAcroname outfile=&outfile %qsysfunc(pathname(&outfile));

  *
  * create global return var 
  *;
  %if %symexist(&returnName) = 0 %then %do;
    %global &returnName;
  %end;

  data _null_;
    length
      msg $ 1024
      rec $ &chunkSize
      outfmt $ 32
    ;

    *
    * open input and output file with binary mode
    *;
    fid_in = fopen("&infile", 'S', &chunkSize, 'B');

    *
    * check for unsuccessful open
    *;
    if fid_in <= 0 then do;
      msg = sysmsg();
      putlog "ERROR: &sysMacroname open failed for &infile";
      putlog msg;
      call symputx("&returnName",8);
      stop;
    end;

    fid_out = fopen("&outfile", 'O', &chunkSize, 'B');

    *
    * check for unsuccessful open
    *;
    if fid_out <= 0 then do;
      msg = sysmsg();
      putlog "ERROR: &sysMacroname open failed for &outfile";
      putlog msg;
      call symputx("&returnName",8);
      stop;
    end;

    *
    * we will keep track on the number of bytes processed
    *;
    bytesProcessed = 0;

    *
    * read loop on input file
    *;
    do while( fread(fid_in) = 0 );
      call missing(outfmt, rec);
      rcGet = fget(fid_in, rec, &chunkSize);

      *
      * need this information for write processing
      *;
      fcolIn = fcol(fid_in);

      *
      * need a format length to handle situations
      * where last chars in rec are blank
      * true: normal situation
      * false: last chunk of data at end of file
      *;
      if (fColIn - &chunkSize) = 1 then do;
        fmtLength = &chunkSize;
      end;
      else do;
        fmtLength = fColIn - 1;
      end;

      *
      * prepare the output format
      * and write rec
      *; 
      outfmt = cats("$char", fmtLength, ".");
      rcPut = fput(fid_out, putc(rec, outfmt));
      rcWrite = fwrite(fid_out);

      *
      * keep track of bytes
      *;
      bytesProcessed + fmtLength;    

      *
      * just in case
      *;
      maxRc = max(rcGet, rcPut, rcWrite);
      if maxRc > 0 then do;
        putlog "ERROR: &sysMacroname checklog " rcGet= rcPut= rcWrite=;
        call symputx("&returnName", 8);
      end;
    end;

    putlog "NOTE: &sysMacroname processed " bytesProcessed "bytes";
    rcInC = fclose(fid_in);
    rcOutC = fclose(fid_out);
    maxRc = max(rcInC, rcOutC);

    if maxRc > 0 then do;
      putlog "ERROR: &sysMacroname checklog " rcInC= rcOutC=;
      call symputx("&returnName", 8);
    end;
    else do;
      call symputx("&returnName", 0);
    end;
  run;

  filename _bcin clear; 

  %let endTime = %sysfunc( datetime() );
  %put NOTE: &sysMacroname end %sysfunc( putn(&endTime, datetime19.));
  %let diffTime = %sysevalf( &endTime - &startTime );
  %put NOTE: &sysMacroname processtime %sysfunc( putn(&diffTime, tod12.3));
%mend;
