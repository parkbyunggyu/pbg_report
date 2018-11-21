------------------------------------------------------------------------------------
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
------------------------------------------------------------------------------------

# pbg_report
AWR report for PostgreSQL - database check script 


##1. 스트립트에 대한 설명
   이 스크립트는 PostgreSQL DATABASE를 점검하는 쉘스크립트로써 
   점검에 필요한 정보들을 묻는 항목들이 있습니다.
   각 항목들에 정확한 값을 입력하지 않을 경우 올바른 값이 입력될때 까지 계속 물어 입력하게 하며, 
   항목에서 빠져나와 스크립트를 종료시키고 싶다면 q나 Q를 입력해빠져나올수 있습니다.



##2. 장점 
   1) 이 스크립트는 두개의 부분으로 나뉘어져 있습니다.
      첫번째 부분은 현재 서버가 Database서버인지 확인하고
      Database서버라면 Database의 성능에 대해 점검하고
      Database서버가 아니라면 Database의 성능에 대해 분석하지 않습니다.

      두번째 부분은 Log 파일의 위치에 있는 log들을 분석하는 부분입니다.
      이러한 구성은 PostgreSQL log 파일이 있는 서버가 꼭Database서버가 아니여도
      DB log 파일만 있다면 Database에서 발생했던 log를 분석할수 있다는 장점이 있으며, 
      Window 서버에서 발생한 PostgreSQL 서버의 DB log를Linux 서버로 업로드해 분석이 가능합니다.

   2) Text 기반으로 분석을 하여, runlevel이 5 이하여도 Database에 대한 점검이 가능

   3) 다른 점검 툴처럼 사전에 log_line_prefix를 설정하지 않아도 log파일에 기록되어있는 log_line_prefix를 읽어분석에 활용



##3. 스크립트 실행시 진행순서는 다음과 같습니다.

1) Database 서버인지 아닌지 확인 ( Y / N ) 입력
 - Y 입력시 Database에 대한 DATA위치의 정보를 받아, 아래의 정보를 pbg_serYYYYmmddHHMMSS.log에 기록합니다.
   * Server 버전
   * DataBase 버전
   * Core 수
   * load average
   * 디스크 I/O 성능
   * DATA PARTITION 사용량
   * XLOG PARTITION 사용량
   * ARCH PARTITION 사용량
   * TABLESPACE PARTITION 사용량
   * Database의 파라미터 권고값과 현재 설정값

 - Y 입력시 Database가 작동중이라면 아래의 정보를 pbg_serYYYYmmddHHMMSS.log에 기록하며
   Database가 꺼져있는 경우 기록하지 않습니다.
   * Database 사이즈
   * Database Age
   * Tablespace 사용량
   * Buffer cache hit 율
   * Dead row 가 많은 Table list
   * Index 사용률이 적은 Index list

2) 점검할 Log가 있는 LOG 디렉토리의 전체경로를 묻습니다. 해당 경로에는 오로지 PostgreSQL 로그만 존재해야하며
   Log파일 이외에 다른 파일이 섞여있을시 Log 파일의 전체 경로를 계속 묻습니다.
   Log디렉토리의 경로를 정확히 입력하였다면, 점검이 끝난후 다음과 같은 점검 report가 생성됩니다.
   
   * pbg_errYYYYmmddHHMMSS.log   : 문법 Error log 발생건수와 문법 Error 내용 기록 보고
   * pbg_slowYYYYmmddHHMMSS.log  : Slow log 발생 건수, 발생시간, 경과 시간, 쿼리 내용 기록 보고 
   * pbg_tempYYYYmmddHHMMSS.log  : Temp file 사용 발생 건수, 발생 시간, Tempfile 사용 용량, 쿼리내용 기록 보고
   * pbg_lockYYYYmmddHHMMSS.log  : Lock 발생시 대기큐에 쌓였던 3~5개의 queue 들과(PID), 수행됬던 쿼리내용 기록 보고
   * pbg_shtYYYYmmddHHMMSS.log   : Shutdown 발생기록 보고
   * pbg_warnYYYYmmddHHMMSS.log  : Warning 발생기록 보고
   * pbg_panicYYYYmmddHHMMSS.log : Panic 발생기록 보고
   * pbg_fatlYYYYmmddHHMMSS.log  : FATAL 발생기록 보고
   * pbg_serYYYYmmddHHMMSS.log   : 상위 모든 기록과, Server 리소스 및 Database 리소스 분석 기록 보고

문의 사항이 있다면 bkbspark0725@naver.com 에 문의를 주세요.

