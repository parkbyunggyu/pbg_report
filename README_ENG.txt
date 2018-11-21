   Copyright [2018] [Parkbyunggyu as pbg]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

# pbg_report
AWR report for PostgreSQL - database check script 

##1. This script is ...
   This script is a shell script that checks PostgreSQL DATABASE.
   There are items asking for information necessary for inspection.
   If you do not enter an exact value for each item, 
   you will be asked to continue typing until the correct value is entered. 
   If you want to exit the item and exit the script, you can exit by typing q or Q.

   
   
##2. Advantages
   (1) This script is divided into two parts.
      The first part checks whether the current server is a database server,
      If it is a database server, check the performance of the database,
      Unless it is a database server, it does not analyze the performance of the database.

      The second part is the analysis of the logs at the location of the log file.
      This configuration is not necessarily a PostgreSQL Database server,
      If you only have a log file, you can analyze the log that occurred in the database use this script.
      You can upload DB log of PostgreSQL server from Window server to Linux server for analysis.
	  
   (2) This script is text based and can check the database even if the runlevel is 5 or less.
   (3) Even if you do not set "log_line_prefix" in advance like other checking tools, 
      this script reads "log_line_prefix" recorded in log file to analyze
   


   
##3. The procedure for executing the script is as follows.

(1) Check, dose this server is a database server or not. (Y / N) input
 - When you type "Y", the script asks for information about the DATA location for the database.
   And record the following information in "pbg_serYYYYmmddHHMMSS.log".
   * Server version
   * DataBase version
   * Core count
   * load average
   * Disk I/O performance
   * DATA PARTITION usage
   * XLOG PARTITION usage
   * ARCH PARTITION usage
   * TABLESPACE PARTITION usage
   * Database parameter recommand value and now value

 - If "Y" is entered and the database is running, 
   the script writes the following information to "pbg_serYYYYmmddHHMMSS.log".
   And script does not log if Database is shutdown.
   * Database Size
   * Database Age
   * Tablespace usage
   * Buffer cache hit ratio
   * Table list with many dead rows
   * Low utilization Index list

(2) The script asks for the full path to the LOG directory that contains the Log to check. 
   Only the PostgreSQL log must exist in the path.
   If there are other files in addition to the log file, 
   it keeps asking for the full path of the log file.
   If you have correctly entered the path to the Log directory, 
   the following check report will be generated after the check is completed.
   
   * pbg_errYYYYmmddHHMMSS.log   : Syntax Error log Number of occurrences, Syntax Error Record, report
   * pbg_slowYYYYmmddHHMMSS.log  : Slow log occurrence count, occurrence time, elapsed time, query report 
   * pbg_tempYYYYmmddHHMMSS.log  : Temp file Usage count, occurrence time, Tempfile usage capacity, query report
   * pbg_lockYYYYmmddHHMMSS.log  : 3 ~ 5 queues (PID), which are accumulated in the waiting queue when a lock occurs, query report
   * pbg_shtYYYYmmddHHMMSS.log   : Report of shutdown occurrence
   * pbg_warnYYYYmmddHHMMSS.log  : Report of WARNING occurrence
   * pbg_panicYYYYmmddHHMMSS.log : Report of PANIC occurrence
   * pbg_fatlYYYYmmddHHMMSS.log  : Report of FATAL occurrence
   * pbg_serYYYYmmddHHMMSS.log   : Reports all top records, Server Resource and Database Resource Analysis history

If you have any questions, please contact me at bkbspark0725@naver.com.
