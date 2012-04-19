package Test::AutomationFramework; 
use 5.012003;
use strict;
use warnings;
use Date::Manip;
use File::Path;
use Test::More;
use Getopt::Long;
use File::Copy;
use File::Find;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw(
help
processTCs
processTC
processProperty
genDriver
);


our $VERSION = '0.054';   
	my %tsProperty;my $propertyOp='';	my $regression=0; my $help=0; my $sleep4Display = 0; my $notUsegetTCName= 0;
	my $scriptName = $0; $scriptName =~ s/\\/\\\\/g; my $web_ui_title="Test Automation Framework";
	my $tcNamePattern	= "TC*";
	my $tsProperty    	= 'tsProperty.txt';
	my $reportHtml  	= 'index.htm';
	my $reportHtml1 	= '_tcReport_.html';
	my $reportHistoryHtml 	= '_tcReportHistory_.html';
	my $SvrDrive = 'c:/_TAF'; 
	my $SvrProjName = '_testSuit_'; 
	my $SvrTCName = '_testCase_';
	my $SvrTCNamePattern = "*"; 
	my $SvrPropNamePattern = '.*';
	my $SvrPropValuePattern = ".*";
	my $SvrTCNameExecPattern = ".".$SvrTCNamePattern;
	my $tcOp= 'list';	
 	my $pr2Screen = 1;
	my $SvrLogDir = ''.$SvrProjName.'';


sub new { my $package = shift;
	return bless({}, $package);
}

sub tcLoop {
	if ($pr2Screen == 1) {print "Processing ......\n" ; } else { print "";}
	#  &tcPre(); my $returnValue = &tcMain(); &tcPost(); 
	   &tcPre(); my $returnValue = &tcMain_(); &tcPost(); 
	if ($pr2Screen==1) {print " - Completed -"; } else { print "";}
	return $returnValue;
}
sub tcPre {
	##################### PrePRocessor #####################
 	&createFile($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml1,"");
 	&createFile($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHistoryHtml,"");
 	&appendtoFile($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHistoryHtml,"<html><body><pre>\n");
	########################################################
}
sub tcMain {
	##################### Test Execution ###################
	my $returnValue ='';
	foreach my $eachTC (<$SvrDrive/$SvrProjName/$SvrTCNamePattern>) {				# TC Filter
		if ( &matchProperty ($SvrPropNamePattern, $SvrPropValuePattern, $eachTC) =~ /true/i) {	# Property Filter
				$eachTC = &getRoot($eachTC);
			if ($propertyOp !~ /^\s*$/) { printf "%20s\n", &processProperty($eachTC, $propertyOp); }  # PropertyManagement
			elsif (($tcOp !~ /^\s*$/)&&(&getRoot($eachTC)=~/$SvrTCNameExecPattern/))  { 
				&updateWeb($eachTC,1);
				$returnValue = $returnValue. &processTC("","$tcOp=$eachTC",$pr2Screen)."\n";   	  # TC Execution
				sleep $sleep4Display;
				&updateWeb($eachTC,0);
		    	}
 			&logTC($eachTC);						# TC Logging
			# &reportTC($eachTC,"","lastValue");				# TC Reporting	-> _tcReport_.html
 			&reportTCHistory($eachTC);					# TC ReporHistory -> _tcReportHistory_.html
		}
	}
	return $returnValue;
	########################################################
}

sub tcMain_ { $notUsegetTCName= 1; find(\&recursiveSearchtcMain, $SvrDrive); }
sub recursiveSearchtcMain() { 
	my $returnValue ='';
	if ($SvrTCNamePattern eq '*') { $SvrTCNamePattern = '.*';} 
	if (($File::Find::name =~ /tc.pl/) && ($File::Find::name =~ /$SvrDrive\/$SvrProjName/i) && ($File::Find::name =~ /$SvrTCNamePattern/i))  # TC Filter
	{	my $eachTC = &getRoot($File::Find::name);	
		$SvrTCName = &getDir($File::Find::name);
		#if ( &matchProperty ($SvrPropNamePattern, $SvrPropValuePattern, $eachTC) =~ /true/i) {	# Property Filter
		$eachTC = &getRoot($eachTC);
		if ($propertyOp !~ /^\s*$/) { printf "%20s\n", &processProperty($eachTC, $propertyOp); }  # PropertyManagement
		elsif (($tcOp !~ /^\s*$/)&&($SvrTCName =~/$SvrTCNameExecPattern/))  { 
			# print "pb: $SvrTCName, $eachTC, $SvrTCNameExecPattern \n"; 
			&updateWeb(&getDir($File::Find::name),1);
			$returnValue = $returnValue. &processTC("","$tcOp=$eachTC",$pr2Screen)."\n";   	  # TC Execution
			sleep $sleep4Display;
			&updateWeb(&getDir($File::Find::name),0);
		}
 		&logTC($eachTC);						# TC Logging
		# &reportTC($eachTC,"","lastValue");				# TC Reporting	-> _tcReport_.html
 		&reportTCHistory($eachTC);					# TC ReporHistory -> _tcReportHistory_.html
		#}	# Property Filter 
	} # TC Filter
}
sub tcPost {
	##################### Post PRocessor ###################
 	&appendtoFile($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHistoryHtml,"</pre></body></html>\n");
	&prHtml1();
  	&appendtoFileFile($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml1, $SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml);
	&prHtml2();
	########################################################
} 

sub updateWeb {
	my  %tsProperty;
 	my $tcname = 'TC_tc1'; $tcname = shift if @_;	
 	my $scrollamount = 0 ; $scrollamount = shift if @_;
	$tcname = &getTCName($tcname); $tcname =~ s/\\/\//g;

	if (-e $SvrDrive.'/'.$SvrProjName.'/'.$reportHtml) {
 		open Fin, $SvrDrive.'/'.$SvrProjName.'/'.$reportHtml;
 		open Fout, ">".$SvrDrive.'/'.$SvrProjName.'/'.$reportHtml."_";
 		while ($_ = <Fin>) {
 			my $tcnameTmp = $tcname;
 			if ( $_ =~ /$tcnameTmp/i) {
 				$_ =~ /scrollamount=\s*(\d+)\s*/;
 				$_ =~ s/scrollamount=\s*$1\s*/scrollamount=$scrollamount/;
 			} 
 				print Fout $_;
 		}
 		close Fout;
 		close Fin;

		move ($SvrDrive.'/'.$SvrProjName.'/'.$reportHtml."_", $SvrDrive.'/'.$SvrProjName.'/'.$reportHtml);
	}
	return "tcCtr_Dynamics=$scrollamount";
}

################################################################################
#        
################################################################################

sub readTestSuitProperty {
	if ( -e $SvrDrive.'/'.$SvrProjName.'/'."tsProperty.txt") {
	open Fin, $SvrDrive.'/'.$SvrProjName.'/'."tsProperty.txt";
	while ($_ = <Fin>) {
		chop;
 		if ($_ =~ /web_ui_title\s*:(.+):\s*web_ui_title/)  { $web_ui_title = $1;}
		my $tcname, my $tcdesc;
		# ($tcname, $tcdesc) = split /,/, $_;
		($tcname, $tcdesc) = split /[\|]/, $_;
		if ($tcdesc) {
		$tcname =~ s/^\s*//; $tcname =~ s/\s*$//;  # $tcdesc =~ s/^\s*//;
		$tsProperty{$tcname}= $tcdesc;
		}
	}
	close Fin;
	}
}

################################################################################
#	Subroutine Name : logTC
#		Function: create TC _tcLog.html for each TC
#	Input Parameters: Test Case name
#	Output/Returns  : c:\inetpub\wwwroot\*.html
################################################################################
sub logTC {		# 	Update TC Log on webUI (TH:WebUI)
    my $currentTime  = &UnixDate( "now", "%m/%d/%Y %H:%M:%S %Z" );
    my $tcname       = shift; $tcname = &getTCName ($tcname);
	 if (&getTCLogFname($tcname) =~ /_tcLog\.txt\s*$/ ) { 
	    my 	$webLogText =  &readFile("$tcname\\_tcLog.html");
	       	$webLogText =~ s/<html>\s*<body>\s*<pre>\s*//;
	       	$webLogText =~ s/<\/pre>\s*<\/body>\s*<\/html>\s*//;
	       	$webLogText =~ s/\n/_nl_/g;
	       	$webLogText =~ s/\s*_nl_\s*/\n/g;
    		my $fileText = &readFile(&getTCLogFname($tcname)); # todo Histery
    		if (-e $tcname) {;} else {mkpath $tcname;}
	 	open Fout, "> $tcname\\_tcLog.html" || die "Warning: $tcname\\_tcLog.html doesn't exist\n";
		print Fout "<html><body><pre>\n";
         	print Fout "-------------------- Update on $currentTime Start-------\n";
    		print Fout  $fileText;
         	print Fout "\n-------------------- Update on $currentTime End --------\n"; 
         	print Fout "</pre></body></html>\n";
         	close Fout;
	 } elsif (&getTCLogFname ($tcname) =~ /_tcLogAppend\.txt\s*$/) { 
	    my  $webLogText =  &readFile("$tcname\\_tcLog.html");
	        $webLogText =~ s/<html>\s*<body>\s*<pre>\s*//;
	        $webLogText =~ s/<\/pre>\s*<\/body>\s*<\/html>\s*//;
	        $webLogText =~ s/\n/_nl_/g;
       		$webLogText =~ s/\s*_nl_\s*/\n/g;
    		my $fileText = &readFile(&getTCLogFname($tcname)); # todo Histery
    		if (-e $tcname) {;} else {mkpath $tcname;}
		open Fout, "> $tcname\\_tcLog.html" || die "Warning: $tcname\\_tcLog.html doesn't exist\n";
		print Fout "<html><body><pre>\n";
		print Fout $webLogText;
         	print Fout "-------------------- Update on $currentTime Start-------\n";
    		print Fout  $fileText;
         	print Fout "\n-------------------- Update on $currentTime End --------\n";
         	print Fout "</pre></body></html>\n";
         	close Fout;
	 } else {
    		if (-e $tcname) {;} else {mkpath $tcname;}
		open Fout, "> $tcname\\_tcLog.html" || die "Warning: $tcname\\_tcLog.html doesn't exist\n";
		print Fout "<html><body><pre>\n";
         	print Fout "-------------------- Update on $currentTime Start-------\n";
    		print Fout "$tcname has no log";
         	print Fout "\n-------------------- Update on $currentTime End --------\n";
         	print Fout "</pre></body></html>\n";
         	close Fout;
	 } 
	 return " tcLog[Append].[txt|html] are refreshed";
}

################################################################################
#	Subroutine Name : getTCLogFname
#		Function: get valid Log (new log) fname 
#	Input Parameters: c:\TC*\_thLog.txt
#	Output/Returns  : noLog or hasWWWLog
################################################################################
sub getTCLogFname	{    	# 	Determine if a log exists (TH:TC Report)
    my $tcName  = shift;
    my ( $dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
		$size, $atime, $mtimePropertyFile, $ctime, $blksize, $blocks
	    );
	my $mtimeLogWeb; 

    if (-e $tcName.'\\thProperty.txt' )
     {
	    (
		$dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
		$size, $atime, $mtimePropertyFile, $ctime, $blksize, $blocks
	    ) = stat($tcName.'\\'.'thProperty.txt');
    }

    my $tcNameLog = $tcName."\\_tcLogAppend.txt";
    if (-e $tcNameLog) {
	    my (
		$dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
		$size, $atime, $mtimeLog, $ctime, $blksize, $blocks
	    ) = stat($tcNameLog);
		if ($mtimePropertyFile - $mtimeLog>= 0 ) { return $tcNameLog; }
    }

    $tcNameLog = "$tcName\\_tcLog.txt";
    if (-e $tcNameLog) {
	    my (
		$dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
		$size, $atime, $mtimeLog, $ctime, $blksize, $blocks
	    ) = stat($tcNameLog);
	    if ( $mtimePropertyFile - $mtimeLog>= 2 ) { return $tcNameLog; }
    }

#	todo: for IIS UI 
#    $tcNameLog = "c:\\Inetpub\\wwwroot\\_tcLogs_\\$tcName.html";
#    my (
#        $dev,  $ino,   $mode,  $nlink, $uid,     $gid, $rdev,
#        $size, $atime, $mtimeLog, $ctime, $blksize, $blocks/p;
#    if ( -e $tcNameLog ) { return $tcNameLog; }
    return "noLog"; 
}

################################################################################
#	Subroutine Name : reportTCHistory
#		Function: append TC result History to htmlLog
#	Input Parameters: Test Case name
################################################################################
sub reportTCHistory {
	my $tcname = shift;
	my $fileText = sprintf "%10s %s", "", &reportTC($tcname,"","History");
	&appendtoFile ($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHistoryHtml, " ---------------------- TestCase: <a name=\"".&getTCName($tcname)."\"> ".&getTCName($tcname)." </a>-----------------------\n");
	&appendtoFile ($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHistoryHtml, $fileText);
}


################################################################################
#	Subroutine Name : reportTC
#		Function: report TC results on STDOUT and Update TCProj HTML
#	Input Parameters: TC Name
#			  TC PropertyName = tcRunResult
#			  TC Report Type: 0 = latest 1 = historyical
#	Output/Returns  : TC Reports displayed on webUI
################################################################################
sub reportTC() {		# TC Report Function (TH:TC Report)
    my $cmd=''; $cmd = shift; if ($cmd !~ /^\s*cmd\s*=/i) { unshift @_, $cmd; } ;
    my $timeSpan  = "2000!now"; 
    my $tcname          = $_[0]; my $propertyPattern = $_[1]; my $reportType = $_[2]; 
    $tcname = &getTCName($tcname);
    my ($timeSpanStart, $timeSpanEnd, $isInSpan, $returnValue, $beautifiedStr, $beautifiedStr4Web); 
    my ($propertyName, $startTime, $endTime, $comment1, $comment2) ;
    my $passCtr =0; my $failCtr = 0; my $totalTime=0; my $avgResponseTime; my $propertyValue ='';
    my $totalTimeDummy;
	&readTestSuitProperty();
    if( $propertyPattern =~ /^\s*$/) {   $propertyPattern = 'tcRunResult';}
    if( $reportType =~ /^\s*$/) {   $reportType = 'lastValue';}

     if ($timeSpan) { $_ = $timeSpan;
 	    ($timeSpanStart, $timeSpanEnd ) = split( /!|\|/, $timeSpan );
 	    $timeSpanStart = &ParseDate($timeSpanStart);
 	    $timeSpanEnd   = &ParseDate($timeSpanEnd);
 	}
    open Fin, "$tcname/thProperty.txt" || die "Can't open file:$!";
    while ( $_ = <Fin> ) { chop;
         if ( $_ =~ /$propertyPattern/i ) {
                ( $propertyName, $propertyValue, $startTime, $endTime, $totalTimeDummy, $comment1, $comment2) = split( '\|', $_);
                my $flag1 = &Date_Cmp( &ParseDate($startTime), &ParseDate($timeSpanStart) );
                my $flag2 = &Date_Cmp( &ParseDate($timeSpanEnd), &ParseDate($endTime) );
                if   ( ( $flag1 >= 0 ) && ( $flag2 >= 0 ) ) { $isInSpan = 1; }
                else                                        { $isInSpan = -1; }
		my $date1=&ParseDate($startTime); my $date2=&ParseDate($endTime); my $delta=&DateCalc($date1,$date2); $delta =~ s/\+//g;
		my ($Y,$M,$W,$D,$H,$MIN,$S) = split /:/, $delta;
		my $totalSec = $D * 24 * 3600 + $H * 3600 + $MIN * 60 + $S;
		if ($propertyValue =~ /^\s*[\d|.]+\s*$/) { $totalSec = $propertyValue; $propertyValue = "Perf";}
             if ( $isInSpan == 1 ) {
		 if ( $propertyPattern =~ /tcRunResult/i ) {
		      $beautifiedStr = sprintf "%15s %-15s %-25s%-s", $propertyValue, $totalSec.'s', $startTime, $comment1;
		      if ($propertyValue =~ /pass/i) {$passCtr++; $totalTime =$totalTime + $totalSec;}
		      if ($propertyValue =~ /fail/i) {$failCtr++; $totalTime =$totalTime + $totalSec;}
		 } else {
                 	$beautifiedStr = $_;
             	 }    # endif for /tcRunResult/
                 if ( $reportType =~ /history/i ) {    		# return property history
                     $returnValue .= "$beautifiedStr\n";
                 }
                 elsif ( $reportType =~ /lastValue/i ) {    	# returen last property
                     $returnValue = $beautifiedStr;
                 }
                 elsif ( $reportType =~ /forWeb/i ) {    	# for the web
                         $returnValue .= $beautifiedStr4Web;
                     }
	     } # endif for InSpan
         }    # endif for /propertyPattern/
    }

    	if ($passCtr + $failCtr == 0) { 
	$avgResponseTime = 0; } else {
	$avgResponseTime = $totalTime / ($passCtr + $failCtr); 
	}
	my $qtpHost; my $ATResultFname; my %color; my $color = 'gray'; my @color; my $colorIndex = 0; my $QASvrName; 
	if ($propertyValue =~ /pass/i) { $color = "Green"; } elsif ($propertyValue =~ /fail/i) { $color = 'Red'; }
	$color[0]=1;

	##### testcase Desc #### 
	my $TCDesc_display ;
	if ($tsProperty{$tcname}) { $TCDesc_display = sprintf "%-80s", $tsProperty{$tcname}; 
	} 
	else { $TCDesc_display = sprintf "%-80s", $tcname; }
	my $dirRoot = &getRoot($tcname); 
	my $TCCtrToolTip = sprintf "Click to exec TC (Avg Response Time %.2fs)", $avgResponseTime; 
	my $TCScrollAmount = 0; my $CtrSeparator = "|";
	my $tmp = sprintf( "<li style=\"color:$color;\"><span style=\"color:black;\"><a href=\"file:\\\\\\$tcname\\_tcLog.html\" title=\"Click to see TC Logs\"> %-80s</a> <a href=\"file:///$SvrDrive/$SvrProjName/${reportHistoryHtml}#$tcname\" title=\"Click to see Pass/Fail history\">Pass/Fail</a>:<font color=\"$color[$colorIndex]\"> <a href=\"file:///$SvrDrive/$SvrProjName/$reportHtml\" onClick=\"RunFile('$scriptName -s drive=$SvrDrive;testsuit=$SvrProjName;testcaseExec=$dirRoot;exec')\"  title=\"$TCCtrToolTip\">%5d$CtrSeparator<marquee width=48 direction=right behavior=alternate loop=10000 scrollamount=$TCScrollAmount>%-5d</marquee></a></font> AvgRespTime: %-10.2f     <font color=\"black\"> TimeSpan: %20s -- %20s       %s </font></span></li>\n",
		$TCDesc_display,
                    $passCtr,
                    $failCtr,
                    $avgResponseTime,
                    &UnixDate( $timeSpanStart, "%Y %m %d %H:%M:%S" ),
                    &UnixDate( $timeSpanEnd,   "%Y %m %d %H:%M:%S" ),
		    $tcname.'/tc.pl',
                );
		if ($cmd =~ /noprint/i) {;} else { &appendtoFile( $SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml1, $tmp );}
     	close Fin;
     	if ($returnValue) {$returnValue =~ s/^\s*//g;} else {$returnValue = "";} 
     	return $returnValue;
}

sub processTCs{
	shift;
	my $isBatchProcessing = 1;
	my $tmp = shift;
	@_ = split /;/, $tmp;
	foreach my $each (@_) {
		if ($each !~ /=/) {
			$isBatchProcessing = 0;
			if (($each =~ /\blistVars\b/i) || ($each =~ /\bgetVars\b/i)) { return &getGlobalVars();
			} elsif ($each =~ /\bprintVars\b/i) { print &getGlobalVars(); next ;
			} elsif ($each =~ /\bexec\b/i) { ;
				&setGlobalVars("","tcOP=exec");
				$isBatchProcessing = 1;
			} elsif ($each =~ /\blist\b/i) { ;
				&setGlobalVars("","tcOP=list");
				$isBatchProcessing = 1;
			} elsif ($each =~ /\blistAll\b/i) { ;
			 	$SvrTCNamePattern =".*";  &listAll(); 
				$isBatchProcessing = 0;		
			} else  {
				my $str =  "\&$each();"; my $rst = eval $str; next;  
			}
		} else {
		$each =~ /^\s*(\S+)\s*=\s*(\S+)\s*/; my $varName = $1; my $varValue = $2;
		if (($varName !~ /^\s*$/) && ($varValue !~ /^\s*$/)) {
			$isBatchProcessing = 1;
 			if (&setGlobalVars ("","$varName=$varValue;") == 1 ) 		{ 
				; }
			else {
				$isBatchProcessing = 0; my $rst = &processTC("",$each) ;
			}
	 	}
		}
	} # end of each
	if ($isBatchProcessing == 1) {&tcLoop();}
}

################################################################################
#	Subroutine Name : process Test Case
#		Function: wrapper for Test Case management functions
#	Input Parameters: PropertyOP
#	Output/Returns  : tcName and propertyO/proc
################################################################################
sub processTC {
	# my $tcOP = ''; 
	    my $tcname; my $cmd="";
	    shift; my $tcOP= ''; $tcOP = shift if (@_); 
	    my $prMsg = '' ; $prMsg= shift if @_;
	     $tcOP =~ /\s*([\w|\d]+)\s*(=)?\s*(\w+)?\s*([;|\/])?(\s*\S+\s*)?/;  
	    $tcOP = $1; $tcname = $3; $cmd = $5; $prMsg = $pr2Screen;
	    ######## This is for TCs processing (Batching)
		if ($tcOP =~ /\blistAll\b/i) {
			# SvrTCName as a regExp
			if ($tcname =~ /^\s*$/) { $SvrTCNamePattern =".*";} else { $SvrTCNamePattern = $tcname; } 
			&listAll(); 
			return; 
			}
	    ######## The following are for TC processing 	    
 	    if ((defined $tcname) && ($tcname =~ /^.$/) && ($cmd =~ /:[\\|\/]/)) {
 			$tcname = $tcname.$cmd; # handle -s delete=c:\_ts1_
 	    }

	    $tcname =  &getTCName($tcname); 
	    my $rst; 
	    if ( $tcOP =~ /^\s*create/i ) {
		    if ($cmd) { $rst = &createTC("cmd=$cmd",$tcname); }
		    else { $rst = &createTC($tcname); }
            } elsif ( $tcOP =~ /^\s*exec\b/i ) {
		    $rst = &execTC($tcname);
            } elsif ( $tcOP =~ /^\s*execAll/i ) {
		    $rst = &tcLoop();
		        return $rst;
            } elsif ( $tcOP =~ /^\s*UpdateWeb/i ) {
		    if (defined $cmd) {;} else { $cmd = 0;}
		    $rst = &updateWeb($tcname,$cmd);
            } elsif ( $tcOP =~ /^\s*log/i ) {
		    $rst = &logTC($tcname);
            } elsif ( $tcOP =~ /^\s*detect/i ) {
		    $rst = &detectTC($tcname, $SvrProjName, $SvrDrive); 
            } elsif ( $tcOP =~ /^\s*getLogName/i ) {
		    $rst = &getTCLogFname(&getTCName($tcname)); 
	    } elsif ( $tcOP =~ /^\s*list|get/i ) {
		    $rst = &getProperties(&getTCName($tcname) , 'tcRunResult', 'latest');
            } elsif ( $tcOP =~ /^\s*printResult/i ) {
		    if (defined $cmd) { $rst =  &reportTCHistory($tcname); }
			else { $rst = &reportTC($tcname,"","lastValue") ;}
            } elsif ( $tcOP =~ /^\s*delete/i ) {
		    $tcOP =~ s/^\s*delete\s*=//g;
		    $tcOP =~ s/\s*$//g;
		    $rst = &deleteTC($tcname);
            } else {
		return "_noProcessedTC_";
	    }
	     	printf "%20s:%30s %s\n", "processTC ($tcOP)", $tcname, $rst  if $prMsg; 
	 	$rst = sprintf "%20s:%30s %s", "processTC ($tcOP)", $tcname,  $rst ;
		return $rst;
}


sub listAll { 
	find(\&recursiveSearchListAll, $SvrDrive); }
sub recursiveSearchListAll() { 
	if (($File::Find::name =~ /tc.pl/) && ($File::Find::name =~ /$SvrTCNamePattern/i))
	{	
		print "$File::Find::name\n"; 
	
	}
}
sub createTC {
	my $cmd='';
	$cmd = shift; if ($cmd !~ /^\s*cmd\s*=/i) { unshift @_, $cmd; } ;
	my $tcNameRoot = "@_";

	my $tcName = &getTCName(@_);
	if( &detectTC($tcName) =~ /exists/ && ($cmd !~ /Over/i)) { # overwrite
		return "Warning $tcName already exist! (-create;cmd=overwrite)" ; } 
	else {
		mkpath($tcName);
		if ($cmd =~ /Perf/i) {  # PerformanceTC
		&createFile( $tcName.'\\'.'tc.pl', "\$| = 1; print \"1234567.89\\n\"; sleep 0; ");
		} elsif ($cmd =~ /Fail/i) { # FailedTC
		&createFile( $tcName.'\\'.'tc.pl', "\$| = 1; print \"fail\\n\"; sleep 0; ");
		} elsif ($cmd =~ /customTC/i) { # CustomTC
		$cmd=~ /customTC:\s*(.+)\s*:customTC/; $cmd =$1; $cmd =~ s/_space_/ /;
		&createFile( $tcName.'\\'.'tc.pl', "\$| = 1; print `$cmd`;");
		} else {
			 &createFile( $tcName.'\\'.'tc.pl', "\$| = 1; print \"pass\\n\"; sleep 0; ");
		}
        	&createPropertyTemplate($tcName);
		my $tmp =<<EOF;
open Fout, '>$tcName\\_tcLogAppend.txt';
print Fout "This is append log file";
close Fout;
exit;
EOF
		if (($cmd =~ /genLog/i) || ($cmd =~ /addLog/i)) {&appendtoFile( $tcName.'\\'.'tc.pl', $tmp) ; undef $tmp; }
	$tcName =~ s/\\\\/\\/g;
	return "is created";
	}
}


sub execTC {
	my $tcName = &getTCName(@_);
	my $timeStart = &getDate(); my $rst=''; 
	if  ( -e "$tcName/tc.pl" ) { 
		my $cmd     = "$tcName/tc.pl"; $rst     = `$cmd`; 
		my $timeEnd= &getDate(); 
	       $rst =~ /(pass|fail|todo|[\d|.]+)$/i; $rst = $1; 
	       if ($rst) {;} else {$rst = "null";}
	       $rst =~ s/^\s*0+//g;
	       my $rstStr = sprintf "%20s|%10s|%s", "tcRunResult",$rst , $timeStart;
	       $rstStr .= "|"; $rstStr .= "$timeEnd"; $rstStr .= "|"; $rstStr .= "0:0:0:0s";
	       $rstStr .= "|"; 
	       if ( $rst =~ /^\s*[\d+|\.]+\s*$/ ) {
		$rstStr .= "Performance Test ($rst) ";
	       } else {
	       $rstStr .= "Functional Test ($rst) ";
	       } 
	       $rstStr .= '|comment2'; 
	       &addProperty(&getTCName($tcName), "add=$rstStr");
	       return $rst;
       }
       else {
		return "tcName: $tcName doesn't exist.\n";
       }

}
sub deleteTC {
	if ($_[1]) { $SvrProjName = $_[1];}
	if ($_[2]) { $SvrDrive = $_[2];}
	my $tcName = &getTCName(@_);
#### 	todo	backup deleted TCs. move ($tcName, $tcName."_".  &UnixDate( "now", "%m_%d_%Y_%H_%M_%S_%Z" ) ."_backup");
	rmtree $tcName;
	return "$tcName is deleted (saved as *_backup)";
}

sub detectTC {
	if ($_[1]) { $SvrProjName = $_[1];}
	if ($_[2]) { $SvrDrive = $_[2];}
	my $tcName = '';
	$tcName = &getTCName(@_);
     	if (-e "$tcName\\tc.pl" ) { return  "exists"; } else { return 'does not exist';}
}

sub getTCName {
	my $SvrProjNameTmp; my $SvrDriveTmp; my $SvrTCNameTmp ;  
	$SvrTCNameTmp = shift if @_; 
	if ($notUsegetTCName==1) { return $SvrTCName;}
	if ($SvrTCNameTmp) {;} else { $SvrTCNameTmp = $SvrTCName; }  
	if ($SvrProjNameTmp) {;} else {  $SvrProjNameTmp = $SvrProjName;}  
	if ($SvrDriveTmp) {;} else {  $SvrDriveTmp = $SvrDrive;}  
	if ($SvrTCNameTmp =~ /[a-z]:/i) {
		return  $SvrTCNameTmp;
	} else {
		return ($SvrDriveTmp.'/'.$SvrProjNameTmp.'/'.$SvrTCNameTmp) ;
	}
}

sub tcAvgResponseTime { # absolete
		my $tcname = shift; if ($tcname) {;} else {print "tcAvgResponseTime lack TCname\n";}
 		my $rst= &reportTC1(&getTCName($tcname),"","history")."\n";				
		@_ = split /\n/, $rst;
		my $ctr =0; my $totalTime =0; # in sec
		for (my $i=0; $i<=$#_; $i++) {
			$_[$i] =~ /^\s*(\w+)\s+(\w+)\s+/;
			my $tmp1 = $2;
			$tmp1 =~ s/s\s*$//g;
			$totalTime = $totalTime + $tmp1; $ctr++; 
		}
		if ($ctr == 0) { return '0.00'; }
		else { return sprintf "%.2f",$totalTime/$ctr;}
}


################################################################################
#	Subroutine Name : processProperty
#		Function: wrapper for property management functions
#	Input Parameters: PropertyOP
#	Output/Returns  : tcName and propertyOp
################################################################################
sub processProperty {
	shift; my $tcname = shift; my $propertyOP = shift; my $rst=""; my $prMsg=0;
	if  ($tcname =~ /:|;/) { $propertyOP = $tcname; $tcname=&getTCName();}
	if (defined $propertyOP) {;} else { $rst = "Warning: wrong format. Correct format is -add=prop:value"; 
		return $rst; }
	if ($propertyOP =~ /;\s*pr2Screen\s*/) { $prMsg = 1; $propertyOP =~ s/;\s*pr2Screen\s*(=\s*\d*\s*)?//; }
	if ( $propertyOP =~ /^\s*add/i ) {
                $rst = &addProperty( &getTCName($tcname), $propertyOP );
        }
        elsif ( $propertyOP =~ /^\s*del/i ) {
                $rst = &deleteProperty( &getTCName($tcname), $propertyOP );
        }
        elsif ( $propertyOP =~ /^\s*reset/i ) {
                ;
        }    # copy to a backup and create a property file
        elsif ( $propertyOP =~ /^\s*modify/i ) {
                $rst = &modifyProperty( &getTCName($tcname), $propertyOP );
        }
        elsif ( $propertyOP =~ /^\s*get|list/i ) {
		    $propertyOP =~ s/^\s*get\s*=//g; $propertyOP =~ s/^\s*list\s*=//g;
		if ($propertyOP =~ /;/ ) {
		    @_ = split /;/, $propertyOP ;
		    $rst = &getProperties(&getTCName($tcname), $_[0], $_[1]);
	    	    } else {
			    $rst = &getProperties(&getTCName($tcname), $propertyOP );
		 }
         }
         elsif ( $propertyOP =~ /^\s*create/i ) {
        	$rst = &createPropertyTemplate($tcname);
         }
         elsif ( $propertyOP =~ /^\s*match|filter/i ) {
		    $propertyOP =~ s/^\s*match\s*=//g;
		    $propertyOP =~ /\s*(\S+)\s*[:|;]\s*(\S+)\s*/; 
        	    $rst = &matchProperty($1, $2, $tcname);
         } else {
	    	    $rst = sprintf "ProcessProperty (no match OP) %40s %20s", $tcname, $propertyOp;
    	 }
	    if ($rst =~ /^\s*$/) { $rst = "_noMatchedPropertyOP_";}
	    if ((defined $prMsg) && ($prMsg ==1)) { print  $rst;}
	    return $rst;
}

################################################################################
#	Subroutine Name : matchProperties
#		Function: return true/false 
#	Input Parameters: Property Name in regExp  
#	Output/Returns  : True/False
################################################################################
sub matchProperty { # &matchProperty("QAOwner","ywang", "TC_tc1");
	my $propertyName = ".*"; my $propertyPattern = ".*"; my %array; my $tcname = "TC_tc1";
	$propertyName = shift if (@_);
	$propertyPattern= shift if (@_);
	$tcname = shift if (@_);

	 if (&getProperties(&getTCName($tcname)) =~ /info:There is no/ ) {
		 return "False";
	 }

	foreach my $each (split /\n/,  &getProperties(&getTCName($tcname))) {
		$each =~ /^\s*(\w+)\s*=\s*(\w+)\s*$/;
		$array {$1}  = $2;
	}
	foreach my $each (sort keys %array) {
		if (($array{$each} =~ /$propertyPattern/) && ( $each =~ /$propertyName/)) { 
			 return "True"; }
	}
	return 'False';
}

################################################################################
#	Subroutine Name : getProperties
#		Function: return Test Case Property
#	Input Parameters: Property Name (regExp)  (tcName, tcPattern, value)
#	Output/Returns  : Property Value
################################################################################
sub getProperties() { 	# get TC Property Names	(TH:TC Managements)
    my %array; my $returnValue = ""; my $propertyPattern = ''; my $tcname=''; my $returnType='';
    if ($_[0]) {$tcname = $_[0];}
    if ($_[1]) {$propertyPattern = $_[1];}
    if ($_[2]) {$returnType = $_[2];} # option = single, value, latest
    if ( -e  "$_[0]\\thProperty.txt" ) { ; } else { return "info:There is no $_[0]/thProperty.txt here";}
    open Fin, "$_[0]\\thProperty.txt" || die "Can't open file:$!";
    while ( $_ = <Fin> ) {
        if ( $_ =~ /^\s*(\S+)\s*\|\s*(\S+)\s*\|/i ) {
	      my $propertyName_ = $1; my $propertyValue_ = $2;

 	      if (($propertyName_ =~ /$propertyPattern/) || ( $propertyPattern eq '')) { # PropertyPattern Filter
  		if ($returnType =~ /^\s*$/) { $returnValue .= sprintf "%-20s=%s\n",$propertyName_, $propertyValue_; }
  		elsif ($returnType =~ /value/i) { 
			$returnValue .= sprintf "%s\n", $propertyValue_;
  		}
  		elsif ($returnType =~ /history/i) { 
			$returnValue .= sprintf "%-20s=%s\n",$propertyName_, $propertyValue_;
  		}
  		elsif ($returnType =~ /latest/i) {$returnValue = "$propertyValue_\n";
  		}
  	       }
	       $array{$propertyName_} = $propertyValue_;
	}
        }
    close Fin;
      if ( $returnType =~ /latest/i) {
	      $returnValue = "";
      foreach my $each ( sort keys %array ) {
   	      if (($each =~ /$propertyPattern/) || ( $propertyPattern eq '')) { # PropertyPattern Filter
   		if ($returnType =~ /^\s*$/) { 
			# $returnValue .= sprintf "%-20s=%s\n",$each,$array{$each}; 
			;
		} elsif ($returnType =~ /value|history/i) { 
			#$returnValue .= "$array{$each}\n";
			;
   		} elsif ($returnType =~ /latest/i) {
			$returnValue .= sprintf "%-20s=%s\n",$each, $array{$each};
			# $returnValue = "$array{$each}\n";
   		}
   		}
       }
       }
    $returnValue =~ s/\s*\n\s*$//g;
    if ($returnValue =~ /^\s*$/) { $returnValue = "_noMatch_";}
    return $returnValue;
}

################################################################################
#	Subroutine Name : modfyProperty
#		Function: modify Test Case Property
#	Input Parameters: Test Case Property Name
#	Output/Returns  : updated c:\TC_*\thProperty.txt
#	Subroutine Name : 
#		Function: 
#	Input Parameters: 
#	Output/Returns  : 
################################################################################
sub modifyProperty() { 	# modify TC Property (TH:TC Managements)
    my $tcname       = $_[0];
    my $propertyName = $_[1];
    $propertyName =~ s/^\s*modify\s*=\s*//g;
    $propertyName =~ /(\w+)\s*:\s*(\w+)\s*/;
    $propertyName = $1;
    my $propertyValue = $2;
    my $cmdStr        = "delete=$propertyName";
    &deleteProperty( $tcname, $cmdStr );
    $cmdStr = "add=$propertyName:$propertyValue";
    &addProperty( $tcname, $cmdStr );
    return "$propertyName is modified to $propertyValue for $tcname";
}

################################################################################
#	Subroutine Name : deleteProperty
#		Function: delete Test Case Property
#	Input Parameters: Test Case Property Name
#	Output/Returns  : update c:\TC_*\thProperty.txt
################################################################################
sub deleteProperty() {	# delete TC Property	(TH:TC Managements)
    my $fname = "$_[0]\\thProperty.txt";
    my $fout  = $fname; $fout =~ s/\.txt/_Dumpster\.txt/;

    my $propertyName = $_[1]; 
    if ($propertyName !~ /\s*del\S*\s*=\s*/) { return "Warning: wrong format  -del=prop1;pr2Screen";}
    $propertyName =~ s/^\s*del\S*\s*=\s*//g; $propertyName =~ s/:\s*\S*//;
    my %array ;
    open Fin, "$fname"; @_ = <Fin>; close Fin;

    open Fout, ">>$fout";
    foreach my $each (@_) {
        if ( $each =~ /^\s*$propertyName\s*\|/i ) { print Fout "$each"; }
    }
    close Fout;

    open Fout, ">${fname}" || die "Can't open $fname:$!";
    foreach my $each (@_) {
        if ( $each !~ /^\s*$propertyName\s*\|/i ) {
            print Fout "$each";
        }
    }
    close Fout;
    return "$propertyName is deleted from $fname";

}

################################################################################
#	Subroutine Name : createPropertyTemplate
#		Function: 
#	Input Parameters: 
#	Output/Returns  : 
################################################################################
sub createPropertyTemplate() { 	# create TC Property File (TH:TC Managements)
    my $timeStr = getDate(); $timeStr = "|$timeStr|$timeStr|0:0:0:0s|Comment1|Comment2";
    my $fname = "@_\\thProperty.txt";
    open Fout, ">$fname";
    printf Fout "%20s|%10s%s\n", 'tcId','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcDesc','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcSPR','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcSCR','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'QA','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'modolID','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'priority','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'openSPR','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcID','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcOwner','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'tcId','null',$timeStr;
    printf Fout "%20s|%10s%s\n", 'resultN','null',$timeStr;
    close Fout;
}

################################################################################
#	Subroutine Name : addProperty
#		Function: add Test Case Property
#	Input Parameters: Test Case Property Name
#	Output/Returns  : updated c:\TC_*\thProperty.txt
################################################################################
sub addProperty() { 	# add TC Property (TH:TC Managements)
    my $timeStr = &getDate(); $timeStr = "|$timeStr|$timeStr|0:0:0:0s|comment1|comment2";
    my $fname        = "$_[0]\\thProperty.txt";
    my $propertyName = $_[1];
    $propertyName =~ s/^\s*add\s*=\s*//ig;
    open Fout, ">>$fname";
    	if ($propertyName =~ /\|/) { # for tcRunResult 
		$propertyName =~ /^\s*(\S+)\s*\|\s*(\S+)\s*\|(.+)\s*$/; 
        	printf Fout "%20s|%10s|%s\n",$1, $2,$3;
	} else {
		$propertyName =~ /^\s*(\S+):(\S+)\s*/; 
        printf Fout "%20s|%10s%s\n",$1, $2,$timeStr;
	}
    close Fout;
    return "$propertyName is added to $fname";
}

sub getGlobalVars { 
	my $return = <<EOF;
	\$SvrDrive 		= $SvrDrive
	\$SvrProjName 		= $SvrProjName
 	\$SvrTCName 		= $SvrTCName
 	\$SvrTCNamePattern 	= $SvrTCNamePattern
 	\$SvrTCNameExecPattern	= $SvrTCNameExecPattern
	\$tcOp			= $tcOp
	\$SvrPropNamePattern 	= $SvrPropNamePattern
	\$SvrPropValuePattern 	= $SvrPropValuePattern
	\$pr2Screen           	= $pr2Screen            
EOF
	return $return;
} 
sub setGlobalVars {
	shift;
	@_ = split /;/, shift;
	my $foundMatch = 0;
	foreach my $each (@_) {
		$each =~ /^\s*(\S+)\s*=\s*(\S+)\s*/;
		my $varName = $1; my $varValue = $2;
		if ($varName =~ /SvrDrive/i) { $SvrDrive = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /SvrProjName/i) { $SvrProjName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /SvrTCName\b/i) { $SvrTCName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /SvrTCNamePattern\b/i) { $SvrTCNamePattern = $varValue; 
				$SvrTCNameExecPattern = $SvrTCNamePattern;
		$foundMatch = 1;}
		elsif ($varName =~ /SvrTCNameExecPattern/i) { $SvrTCNameExecPattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /SvrPropNamePattern\b/i) { $SvrPropNamePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /SvrPropValuePattern/i)  { $SvrPropValuePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bDrive\b/i) 		{ $SvrDrive = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bProjName\b/i) 		{ $SvrProjName = $varValue; $foundMatch = 1;}
		# elsif ($varName =~ /\bTCName\b|testcase\b/i) 		{ $SvrTCName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTCName\b/i) 		{ $SvrTCName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTCNamePattern\b/i) 	{ $SvrTCNamePattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTCNameExecPattern/i) 	{ $SvrTCNameExecPattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btcOp\b/i) 		{ $tcOp= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bPropNamePattern\b/i)  	{ $SvrPropNamePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bPropValuePattern\b/i)  	{ $SvrPropValuePattern= $varValue; $foundMatch = 1;}

		elsif ($varName =~ /\bTestSuit\b/i) 		{ $SvrProjName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTCNameFilter\b/i) 	{ $SvrTCNamePattern = $varValue;$foundMatch = 1;}
		elsif ($varName =~ /\bTCNameExecFilter\b/i) 	{ $SvrTCNameExecPattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTestCaseExec\b/i) 	{ $SvrTCNameExecPattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bTestCase\b/i) 		{ $SvrTCNamePattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bPropNameFilter\b/i)  	{ $SvrPropNamePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bPropValueFilter\b/i)  	{ $SvrPropValuePattern= $varValue; $foundMatch = 1;}

		elsif ($varName =~ /\btsuit\b/i) 		{ $SvrProjName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btname\b/i) 	{ $SvrTCNamePattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bpname\b/i)  	{ $SvrPropNamePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bpvalue\b/i)  	{ $SvrPropValuePattern= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btop\b/i) 		{ $tcOp= $varValue; $foundMatch = 1;}

		elsif ($varName =~ /\bts\b/i) 		{ $SvrProjName = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btn\b/i) 	{ $SvrTCNamePattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btc\b/i) 	{ $SvrTCNamePattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\btne\b/i) 	{ $SvrTCNameExecPattern = $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bop\b/i) 		{ $tcOp= $varValue; $foundMatch = 1;}

		elsif ($varName =~ /\bpr2Screen\b/i)  { $pr2Screen= $varValue; $foundMatch = 1;}
		elsif ($varName =~ /\bnotUsegetTCName\b/i)  { $notUsegetTCName = $varValue; $foundMatch = 1;}

	}
	$foundMatch;
}


sub help {
if ( $^O =~ /MSWin32/ ) {; } else { print "TAF supports Win32 ONLY currently.\n"; exit; }

my $help=<<EOF;
-----------------------------------------------------------------------------------------------------------------------
taf.pl testsuit=_ts1_;list 
taf.pl testsuit=_ts1_;testcase=_tc1_;list 


taf.pl  -processTC or -tc arg=[tcName;cmd] create=tc1|list|get|exec=tc1|detect|delete|log|getLogName|printResult;all

	# e.g.  taf.pl -tc create=tc1;fail,overwrite
	        taf.pl -tc create=tc1;fail,genLog;pr2Screen
	        taf.pl -tc create=tc1;performanceTC,genLog;pr2Screen
	        taf.pl -tc delete=tc1;pr2Screen

	-processTCs or -s  arg=[TCOP=list;...]  # e.g.  taf.pl -s TCNamePattern=tc.*
	                                 	#       taf.pl -s list
		Drive=c:;			# c: d: e: ...
		TestSuite=_testSuit_;		# directory 
		TCOp=list;			# List test cases that matches the TCNameFilter and PropertyFilter
		TCName=_testCase_;		# test case name 
		TCNamePattern=*;		# Test Case Name Filter 
		TCNameFilter=*;			# Test Case Name Filter 
		PropNameFilter=.*;		# Property_Name Filter
		PropValueFilter.=.*;		# Property_Value Filter
		pr2Screen;			# Results will be displayed on screen 
		getVars|listVars|printVars	# get or print TAF settings

	-processProperty or -prop arg=[add=prop1:val1]  add|delete|list|get|modify|match|filter

	# e.g   taf.pl -prop list=tc;pr2Screen
	        taf.pl -prop add=prop1:val1;pr2Screen
	        taf.pl -prop match=.*:.*;pr2Screen
	        taf.pl -prop match=propNameFilter:propValFilter

	To create driver (taf.pl): perl.pl -MTest::AutomationFramework -e "help" 

	taf.pl -processTCs create=tc1/fail,overwrite

	Note: 
	-------- c:/_TAF/_ts1_/tsProperty.txt ----------
	web_ui_title: Purge Algorithm Test Cases - based on Tesbed : web_ui_title
	c:/_TAF/purge_testbed/testcase01, 1  Purge Root Node                                             (purge Table11)
	c:/_TAF/_ts1_/_tc1_ , test case 1 desc
	c:/_TAF/_ts1_/_tc2_ , test case 2 desc
-----------------------------------------------------------------------------------------------------------------------
EOF
	print $help;
	&genDriver();

}

sub genDriver {
	if (-e "taf.pl") {;} else {
	open Fout, ">taf.pl";
	print Fout &prDriver(1);
	close Fout;
	print " --> taf.pl\n";
	}

	if (-e "taf.bat") {;} else {
my $str =<<EOF;


REM create test_suit (test_suit)/test_case (tc) 
taf.pl testsuit=_test_suit2_;create=_testcase1_/overwrite  
taf.pl testsuit=_test_suit2_;create=_testcase2_/overwrite
taf.pl testsuit=_test_suit2_;create=_testcase3_/overwrite
taf.pl testsuit=_test_suit2_;create=_testcase4_/overwrite
taf.pl testsuit=_test_suit2_;create=_testcase5_/overwrite
taf.pl testsuit=_test_suit2_;create=_testcase6_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase1_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase2_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase3_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase4_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase5_/overwrite
taf.pl testsuit=_test_suit1_;create=_testcase6_/overwrite
taf.pl testsuit=_test_suit3_;create=_testcase1_/overwrite

REM performance test 
taf.pl test_suit=_test_suit3_;create=_testcase2_/overwrite,perf
REM Failed Functional test 
taf.pl testsuit=_test_suit3_;create=_testcase3_/overwrite,fail
taf.pl testsuit=_test_suit3_;create=_testcase4_/overwrite
taf.pl testsuit=_test_suit3_;create=_testcase5_/overwrite,fail
REM functional test /w log
taf.pl testsuit=_test_suit3_;create=_testcase6_/overwrite,genLog

taf.pl -prTestSuitProperty

REM exec all test_suit under test_suit (test_suit)
taf.pl testsuit=_test_suit1_;exec
taf.pl testsuit=_test_suit1_;testcase=*;exec
taf.pl testsuit=_test_suit1_;testcase=testcase1*;exec

taf.pl testsuit=_test_suit2_;exec
taf.pl testsuit=_test_suit3_;exec

REM Seting the moving bar for showing test-in-prog status
taf.pl testsuit=_test_suit3_;updateWeb=_testcase1_/2
taf.pl testsuit=_test_suit3_;updateWeb=_testcase2_/1
taf.pl testsuit=_test_suit3_;updateWeb=_testcase3_/3
taf.pl delete=c:/_TAF/_test_suit1_

REM taf.pl 'testsuit=_test_suit1_;create=_testcase1_/overwrite,customTC:c:/tmp/purge.pl_space_1:customTC'

\@start "" /b "C:\\Program Files\\Internet Explorer\\iexplore.exe" "C:\\_TAF\\_test_suit3_\\index.htm"


EOF
	open Fout, ">taf.bat";
	print Fout $str;
	close Fout;
	print " --> taf.bat\n";
	my $cmd = 'taf.bat'; system $cmd;
	}
}
sub prTestSuitProperty {
open Fout, ">c:/_TAF/_test_suit3_/tsProperty.txt";
my $str = <<EOF;
web_ui_title: Test Automation Framework : web_ui_title
c:/_TAF/_test_suit3_/_testcase1_| 1  Test case 1 description                            Manual edit please     
c:/_TAF/_test_suit3_/_testcase2_| 2  Test case 2 description for tsProperty.txt         Manual edit please     
c:/_TAF/_test_suit3_/_testcase3_| 3  Test case 3 description for .. tsProperty.txt      Manual edit please     
c:/_TAF/_test_suit3_/_testcase4_| 4  Test case 4 description for ... tsProperty.txt     Manual edit please     
c:/_TAF/_test_suit3_/_testcase5_| 5  Test case 5 description for .... tsProperty.txt    Manual edit please     
c:/_TAF/_test_suit3_/_testcase6_| 6  Test case 6 description for ..... tsProperty.txt   Manual edit please     
EOF
print Fout $str;
close Fout
}

sub prDriver {
	my $driver=<<EOF;
use Test::AutomationFramework;
use Getopt::Long;
	GetOptions(
	    'processTCs|settings|s=s'         => \\\$processTCs,			
	    'processTC|tc=s'                  => \\\$processTC,		
	    'processProperty|property=s'      => \\\$processProperty,		
	    'help'                  	      => \\\$help,	
	    'prTestSuitProperty'              => \\\$prTsProperty,	
	);
\$TAF = new Test::AutomationFramework;
if (\$prTsProperty) {\$TAF->prTestSuitProperty();}
if (\$help) {\$TAF->help();}
if (\$prDriver) {\$TAF->prDriver();}
if (\$processTCs) { \$TAF->processTCs(\$processTCs);}
if (\$processProperty) 	{ \$TAF->processProperty(\$processProperty);}
if (\$processTC) 	{ \$TAF->processTC(\$processTC);}
foreach \$each (\@ARGV) {\$cmdLine =\$cmdLine.\$each.';'; } \$TAF->processTCs(\$cmdLine) if \$cmdLine;

EOF
if (@_) { return $driver;} else { print $driver;}
}


################################################################################
#	Subroutine Name : getDate
#		Function: get current Datetime 
#	Input Parameters: 
#	Output/Returns  : currentDate in the format of 2010-10-02 12:11:22
################################################################################
sub getDate ( ) {	# 	TH:Generic Functions: get current Time (TH:Generic Functions)
    my ( $y, $m, $d, $hh, $mm, $ss ) = (localtime)[ 5, 4, 3, 2, 1, 0 ];
    $y += 1900;
    $m++;
    my $iso_sale_time =
      sprintf( "%d-%02d-%02d %02d:%02d:%02d", $y, $m, $d, $hh, $mm, $ss );
    $iso_sale_time;
}

################################################################################
#	Subroutine Name : appendtoFile
#		Function: append text to a file
#	Input Parameters: 1 Filename 2 String
#	Output/Returns  : New File with the appened text
################################################################################
sub appendtoFile() {  	# TH:Generic Functions: append to file (TH:Generic Functions)
    my $fname = $_[0];
    open Fout, ">>$fname";
    print Fout "$_[1]";
    close Fout;
}

################################################################################
#	Subroutine Name : appendtoFileFile
#		Function: append file1 to file2
#	Input Parameters: 1 Filename 2 String
#	Output/Returns  : New File with the appened text
################################################################################
sub appendtoFileFile() {  	# TH:Generic Functions: append file to file (TH:Generic Functions)
    my $fname = $_[0]; my $fnameOUT = $_[1];
    open Fin, "$fname" || die "Can't open $fname:$!";
    while ($_ = <Fin>) {
    	&appendtoFile($fnameOUT, $_) if ($_ !~ /^\s*$/);
    }
    close Fin;
}

################################################################################
#	Subroutine Name : createFile
#		Function: create a new file
#	Input Parameters: 1 Filename 2 String
#	Output/Returns  : New File with the appened text
################################################################################
sub createFile() {  	# TH:Generic Functions: create to file (TH:Generic Functions)
    my $fname = $_[0];
    if (-e &getDir($fname)) {;} else {mkpath &getDir($fname);}
    open Fout, ">$fname";
    print Fout "$_[1]\n";
    close Fout;
}

################################################################################
#	Subroutine Name : readFile
#		Function: Read a file
#	Input Parameters: Filename 
#	Output/Returns  : String
################################################################################
sub readFile() {  	# TH:Generic Functions: read file (TH:Generic Functions)
    my $fname = $_[0];
    if ( -e $fname ) {
    open Fin, "$fname";
    @_ = <Fin>;
    close Fin;
    return "@_";
    } else { return "";}
}

sub getRoot { my $string = shift; @_ = split /\\|\//, $string; return $_[$#_]; }
sub getDir  { my $string = shift; my $root =&getRoot($string); $string =~ s/([\\|\/])?$root//i; return $string;  }


sub prHtml1 {
&createFile( $SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml, '' );
my $str =<<EOF;
taf.pl       : TAF Driver    
taf.bat      : TCs struc setup
tc.pl        : TC hook       
_tcAppend.txt: TC log  hook 
EOF

	my $strTmp = sprintf "%-60s", "TC Name"; 
	my $TCCtrToolTip = sprintf "Click to exec Test Suit"; 
	my $tmp1 = sprintf("<a href=\"file:///$SvrDrive/$SvrProjName/$reportHtml\" onClick=\"RunFile('$scriptName SysDrive=$SvrDrive;testsuit=$SvrProjName;exec')\"  title=\"$TCCtrToolTip\" </a> ");
		
my $tmp =<<EOF;

<html>
<head> 
<META http-equiv="refresh" content="20"> 
		<HTA:APPLICATION ID="oMyApp" 
		    APPLICATIONNAME="Application Executer" 
		    BORDER="no"
		    CAPTION="no"
		    SHOWINTASKBAR="yes"
		    SINGLEINSTANCE="yes"
		    SYSMENU="yes"
		    SCROLL="no"
		    WINDOWSTATE="normal">
	<script language="JavaScript">
		function RunFile(file) {
			// alert("file is " + file );
			WshShell = new ActiveXObject("WScript.Shell");
			WshShell.Run(file, 1, false);
		}
	</script>
</head>
<body OnLoad ="function1()">
<script type="text/javascript"> if (navigator.appName != "Microsoft Internet Explorer") alert("Please use IE to access TAF's webUI") </script>
<pre>
<p>
<h2> <a href="http://127.0.0.1//Trainings/" title="$str">$web_ui_title</h2> <font size ="2" </font> </a>
<a title=\"latest Test Result pass/fail = Green/Red\">L</a>            <a title=\"Test Case Name\">$strTmp</a>          -Pass/Fail-    <a title=\"pass/fail counts\">${tmp1}Ctr</a>       Average ResponseTime         over time span   ( start Date time  --  end Date Time)           <a title=\"Manual command to exec TC\">-TC Exec Command-</a> </span>
EOF

&appendtoFile ($SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml, $tmp);
}

sub prHtml2 {
my $tmp =<<EOF;
</pre></body>
</html>
<style type="text/css"> a { text-decoration:none} </style> 
EOF
 &appendtoFile( $SvrDrive.'\\'.$SvrProjName.'\\'.$reportHtml, $tmp );
}

__END__
		TAF Function Summary  (Code Name: th.pl as of Sept 27, 2010)
------------------------------------------------------------------------------------------
TH Function Category     Function Name            Function Description
------------------------------------------------------------------------------------------
TH:TC Managements        logIsValid               Verify if a log is valid by comparing TC created T and log create T Commented Done 
TH:TC Managements        tcRunningYN              get the TC result Pass/Fail                                         Commented Done
TH:TC Managements        getProperty              get TC Property Names                                               Commented Done
TH:TC Managements        getPropertyValues        get TC Property Values                                              Commented Done
TH:TC Managements        deleteProperty           delete TC Property                                                  Commented Done
TH:TC Managements        addProperty              add TC Property                                                     Commented Done
TH:TC Managements        modifyProperty           modify TC Property                                                  Commented Done
TH:TC Managements        appendPropFile           append to TC Property File                                          Commented Done
TH:TC Managements        createPropFile           create TC Property File                                             Commented n/a
TH:TC Managements        readProperty             Read TC Property                                                    Commented n/a
TH:TC Managements        updateTCResultProperty   Update TC Property                                                  Commented n/a
TH:TC Managements        genTC                    Generate a HelloWorld TC                                            Commented Done

TH:TC Report             Report                   TC Report Function                                                  Commented Done
TH:TC Report             reportUpdateOnWeb        update TC Report on webUI                                           Commented 
TH:TC Report             logExist                 Determine if a log exists                                           Commented Done

TH:TC Execution          ReportAvgResponseTime    report TC Average Response Time                                     Commented n/a
TH:TC Execution          lastPassFail             get the latest TC Pass/Fail Result                                  Commented Done
TH:TC Execution          longivityPeriod          If the TC in LongivityPeriod                                        Commented 

TH:WebUI                 thWebUIUpdate            Update the webUI based on thProperty.txt                            Commented v2
TH:WebUI                 tcStatusHtmlSync         synchrinize the HTML with with TC Result                            Commented v2
TH:WebUI                 tcStatusHtml             Display the TCStatuse in Html format                                Commented v2
TH:WebUI                 rearrangeWebUI           Update webUI based on thProperty.txt                                Commented v2
TH:WebUI                 tcLog2Web                Update TC Log on webUI                                              Commented v2

TH:Concurrency Control   tcRunningYNOther         get the running TC Status for Concurrency Control.                  Commented v2          
TH:Concurrency Control   tcScheduledYNOther       get the scheduled TC for Concurrency Control.                       Commented v2
TH:Concurrency Control   tcQueue                  TC Queue function for Concurrency Control.                          Commented v2
TH:Concurrency Control   tcDeQueue                TC deQueue for Concurrency Control                                  Commented v2

TH:Email Notification    emailNotification        Process the Outlook email Notification Commands                     Commented v3  
TH:Conti. Integration    thBuzRule                Handle Continuous Integration                                       Commented v3

TH:Assist Functions      genTimeStr               time format function                         			      Commented	                                   
TH:Assist Functions      getIP                    TH:Generic Functions: get IP of local machine                       Commented 
TH:Assist Functions      genThProperty            generate TH property file                                           Commented  
TH:Assist Functions      printLibraryFun          print QTP Library Functions                                         Commented 
TH:Assist Functions      readTestHarnessCmdLine   read Test Harness Cmd Line args                                     Commented 
TH:Assist Functions      genQTPInputs             generate QTP Input files                                            Commented 
TH:Assist Functions      thPropertyUpdate         update TH property                                                  Commented 
TH:Assist Functions      prHelp_short             Print the short Help                                                Commented todo
TH:Assist Functions      prHelp                   print lengthy Help                                                  Commented 
TH:Assist Functions      genQTPDriver             Generic qtpDriver                                                   Commented 
TH:Assist Functions      genQTPLibrary            Generate QTP Library                                                Commented 
TH:Assist Functions      genCmd                   Generate the Test Harness ASP files                                 Commented 

TH:Generic Functions     appendtoFile             TH:Generic Functions: append to file                                Commented Done
TH:Generic Functions     createFile               TH:Generic Functions: create a file                                 Commented Done
TH:Generic Functions     getDate                  TH:Generic Functions: get current Time                              Commented Done
TH:Generic Functions     reverse                  TH:Generic Functions: reverse a Associate Array                     Commented            
TH:Generic Functions     strLen                   Generic Functon: return Str len                                     Commented            
TH:Generic Functions     decrCtr                  Decrease Ctr                                                        Commented            
TH:Generic Functions     incrCtr                  Increase Ctr                                                        Commented            
TH:Generic Functions     getCtr                   Get Ctr                                                             Commented 
TH:Generic Functions     getCurrentTime           TH:Generic Functions: getCurrentTime                                Commented 
TH:Generic Functions     getHost                  getHost function done by SZ Team Charlie and David                  Commented 
TH:Generic Functions     getHostFromIP            Get Host done by SZ Team Charlie and David                          Commented               
------------------------------------------------------------------------------------------


=head1 NAME
Test::AutomationFramework - Test Automation Framework  (TAF)

=head2 SYNOPSIS
	1. Download and install Test::AutomationFramework from CPAN
	2. DOS>perl -MTest::AutomationFramework -e "help"
	3. A WebUI is created, which can display and execute, as well as view test case by *ONE* mouse click
	3. Modify taf.bat for the automated test suit structures 
	4. Modify c:\[test_suit]\[test_case]\tc.pl to plug-in the customer test case
	5. Execute taf.bat to get the webUI
	6. Run test cases, view test result, view test logs with mouse click only. - Enjoy TAF
	7. Please email ywangperl@gmail for questions/suggestions/bugs 

=head2 DESCRIPTION
	TAF manages automated test cases regarding test setup, test query, test execution and 
	test reult reportings without any programming nor reading user manual. 

	TAF defines a automated test case as [c:]\[test_suite]\[test_case]\tc.pl
		tc.pl returns Pass|fail|numerical number
		tc.pl creates tc's log file as [c:]\[test_suite]\[test_case]\tc.pl
		tc.pl creates test suite's webUI at [c:]\[test_suite]\index.htm 

=head1  LICENSE
	This script is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR
    	Yong Wang (ywangperl@gmail.com)

=cut;


1;

use Test::AutomationFramework; $TAF = new Test::AutomationFramework;
foreach $each (@ARGV) { $cmdLine =$cmdLine.$each.';'; } $TAF->processTCs($cmdLine);

rem taf.pl -s ts=_test_suit1_;tcop=list rem ts can't be regExp
rem taf.pl -s ts=_test_suit1_;tn=*1*;tcop=list rem ts can't be regExp
rem
rem taf.pl -s ts=_test_suit1_;tcop=exec rem ts can't be regExp
rem taf.pl -s ts=_test_suit1_;tn=*1*;tcop=list rem ts can't be regExp
rem taf.pl -s printVars	
rem tas.pl help;printVars;ts=_test_suit3_;tcop=list;list
rem tas.pl help;printVars;ts=_test_suit3_;tcop=list;exec

rem taf.pl help;printVars;ts=_test_suit3_;tcop=list;list=regExq  TODO
rem taf.pl help;printVars;ts=_test_suit3_;tcop=list;exec=regExq  TODO
todo: hardcoded c: 
taf.pl listAll
taf.pl ts=_test_suit1_ -listTC
taf.pl ts=_test_suit1_ tc=*test* -listT
rem taf.pl listAll=test_suit1;exec
rem taf.pl listAll=test_suit1;list


taf.pl 'testsuit=PropertyChangedEvent;create=testcase01/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_1:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase02/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_2:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase03/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_3:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase04/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_4:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase05/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_5:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase06/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_6:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase07/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_7:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase08/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_8:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase09/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_9:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase10/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_10:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase11/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_11:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase12/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_12:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase13/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_13:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase14/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_14:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase15/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_15:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase16/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_16:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase17/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_17:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase18/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_18:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase19/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_19:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase20/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_20:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase21/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_21:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase22/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_22:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase23/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_23:customTC'
taf.pl 'testsuit=PropertyChangedEvent;create=testcase23/overwrite,customTC:c:/tmp/testPropertyChangedEvent.pl_space_23:customTC'

taf.pl testsuit=propertyChangedEvent;list
rem taf.pl testsuit=propertyChangedEvent;exec
rem taf.pl testsuit=propertyChangedEvent;updateWeb=_testcase2_/1

-- history --

* using the directory recursive for searching testcases
* CustomTC:....:CustomTC

